//
//  RealmProvider.swift
//  Photos
//
//  Created by Владимир Кваша on 27.11.2020.
//

import RealmSwift

// MARK: - RealmProvider

final class RealmProvider {
    
    // MARK: - Static methods
    
    static func save<T: Object>(items: [T], config: Realm.Configuration) {
        do {
            let realm = try Realm(configuration: config)
            try realm.write {
                realm.add(items, update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    static func saveObject<T: Object>(item: T, config: Realm.Configuration) {
        do {
            let realm = try Realm(configuration: config)
            try realm.write {
                realm.add(item, update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    static func load<T: Object>(type: T.Type,
                                config: Realm.Configuration) throws -> Results<T> {
        let realm = try Realm(configuration: config)
        return realm.objects(type)
    }
    
    static func addProperties(details: DetailedPhoto, to photoId: String) {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            let photos = realm.objects(Photo.self).filter(Constants.detailsFilter, photoId)
            try realm.write {
                photos.first?.setValue(details, forKey: Constants.detailsKey)
            }
        } catch {
            print(error)
        }
    }
    
    static func addTags(tags: [Tags], to details: DetailedPhoto) {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            let properties = realm.objects(DetailedPhoto.self).filter(Constants.tagsFilter, details.url)
            try realm.write {
                properties.first?.setValue(tags, forKey: Constants.tagsKey)
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - Constants

private extension RealmProvider {
    enum Constants {
        static let detailsKey: String = "properties"
        static let tagsKey: String = "tags"
        static let detailsFilter: String = "id = %@"
        static let tagsFilter: String = "url = %@"
    }
}
