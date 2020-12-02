//
//  NetworkService.swift
//  Photos
//
//  Created by Владимир Кваша on 27.11.2020.
//

import SwiftyJSON
import Alamofire

// MARK: - NetworkService

final class NetworkService {
    
    // MARK: - Public methods
    
    public func loadPhotos(completion: @escaping(Result<[Photo], Error>) -> Void) {
        
        let params: Parameters = [
            Constants.clientID : Constants.accessToken]
        
        AF.request(Constants.baseUrl + Constants.photosPath,
                   method: .get,
                   parameters: params).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let photos = json.arrayValue.map {
                            Photo(json: $0) }
                        completion(.success(photos))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                   }
    }
    
    public func loadDetails(id: String,
                            completion: @escaping(Result<DetailedPhoto, Error>) -> Void) {
        let path = Constants.baseUrl + Constants.photosPath + id
        let params: Parameters = [
            Constants.clientID : Constants.accessToken]
        
        AF.request(path, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let details = DetailedPhoto(json: json)
                completion(.success(details))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func loadTags(id: String,
                         completion: @escaping(Result<[Tags], Error>) -> Void) {
        let path = Constants.baseUrl + Constants.photosPath + id
        let params: Parameters = [
            Constants.clientID : Constants.accessToken]
        
        AF.request(path, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let tags = json["tags"].arrayValue.map {
                    Tags(json: $0) }
                completion(.success(tags))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func searchPhotos(byString: String, completion: @escaping(Result<[Photo], Error>) -> Void) {
        let path = Constants.baseUrl + Constants.searchPath
        let params: Parameters = [
            Constants.query : byString,
            Constants.clientID : Constants.accessToken,
            Constants.perPage : Constants.numberPerPage ]
        AF.request(path, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let photos = json["results"].arrayValue.map {
                    Photo(json: $0) }
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


// MARK: - Constants

private extension NetworkService {
    
    enum Constants {
        static let baseUrl: String = "https://api.unsplash.com"
        static let accessToken: String = "JYvlwFM4MUnNNcLTzWLIMZ9GWYvzzg3yig48fvJg6Bk"
        static let photosPath: String = "/photos/"
        static let searchPath: String = "/search/photos"
        static let clientID: String = "client_id"
        static let query: String = "query"
        static let perPage: String = "per_page"
        static let numberPerPage: Int = 20
    }
}
