`//
//  Model.swift
//  Photos
//
//  Created by Владимир Кваша on 27.11.2020.
//

import RealmSwift
import SwiftyJSON

// MARK: - Model

class Photo: Object {
    
    // MARK: - Properties
    
    @objc dynamic var id: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var properties: DetailedPhoto?
    
    // MARK: - Init
    
    convenience init(json: JSON) {
        self.init()
        self.id = json["id"].stringValue
        self.url = json["urls"]["small"].stringValue
    }
    
    // MARK: - PrimaryKey
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - DetailedPhoto

class DetailedPhoto: Object {
    
    // MARK: - Properties
    
    var main = LinkingObjects(fromType: Photo.self, property: "properties")
    @objc dynamic var creationDate: String = ""
    @objc dynamic var uploadDate: String = ""
    @objc dynamic var descr: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var likes = 0
    @objc dynamic var authorName: String = ""
    @objc dynamic var byAvatar = ""
    @objc dynamic var deviceModel = ""
    let tags = List<Tags>()
    
    // MARK: - Init
    
    convenience init(json: JSON, tags: [Tags] = []) {
        self.init()
        self.creationDate = json["created_at"].stringValue
        self.uploadDate = json["promoted_at"].stringValue
        self.descr = json["alt_description"].stringValue
        self.url = json["urls"]["regular"].stringValue
        self.likes = json["likes"].intValue
        self.authorName = json["user"]["name"].stringValue
        self.byAvatar = json["user"]["profile_image"]["large"].stringValue
        self.deviceModel = json["exif"]["model"].stringValue
        self.tags.append(objectsIn: tags)
    }
    
    // MARK: - PrimaryKey
    
    override class func primaryKey() -> String? {
        return "url"
    }
    
}

// MARK: - Tags

class Tags: Object {
    
    // MARK: - Properties
    
    @objc dynamic var name: String = ""
    var properties = LinkingObjects(fromType: DetailedPhoto.self, property: "tags")
    
    // MARK: - Init
    
    convenience init(json: JSON) {
        self.init()
        self.name = json["title"].stringValue
    }
    
    // MARK: - PrimaryKey
    
    override class func primaryKey() -> String? {
        return "name"
    }
}
