//
//  TMUser.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct TMUser {

    
    let uid : String
    let fullname : String
    let about : String
    let mode : SearchMode
    let maximumDistance : Int
    let discoveryEnabled : Bool
    let latitude : Double?
    let longitude : Double?
    let image : String?
    
    init(   uid : String,
            fullname : String,
            about : String,
            mode : SearchMode,
            maximumDistance : Int,
            discoveryEnabled : Bool,
            latitude : Double?,
            longitude : Double?,
            image : String?){
        
        self.uid = uid
        self.fullname = fullname
        self.about = about
        self.mode = mode
        self.maximumDistance = maximumDistance
        self.discoveryEnabled = discoveryEnabled
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
    }

    init?(snapshot : DataSnapshot) {
        guard let dictionary = snapshot.value as? [String : Any?] else {
            return nil
        }
        self.init(uid: snapshot.key, dictionary: dictionary)
    }
    
    
    init?(uid : String, dictionary : [String: Any?]) {
        
        guard let fullname = dictionary[Constants.Keys.Name] as? String else {
            return nil
        }
        
        guard let about = dictionary[Constants.Keys.About] as? String else {
            return nil
        }
        
        guard let mode = dictionary[Constants.Keys.Mode] as? String else {
            return nil
        }
        
        guard let maximumDistance = dictionary[Constants.Keys.MaximumDistance] as? Int else {
            return nil
        }
        
        guard let discoveryEnabled = dictionary[Constants.Keys.DiscoveryEnabled] as? Bool else {
            return nil
        }
        
        self.uid = uid
        self.fullname = fullname
        self.about = about
        self.mode = searchModeFromString(mode)
        self.maximumDistance = maximumDistance
        self.discoveryEnabled = discoveryEnabled
        
        latitude = dictionary[Constants.Keys.Latitude] as? Double
        longitude = dictionary[Constants.Keys.Longitude] as? Double
        image = dictionary[Constants.Keys.ImageUrl] as? String
    }
    
    
    func getValueOrNull(_ value : Any?) -> Any{
        return value != nil ? value! : NSNull()
    }
    
    func json() -> [String: Any]{
        return [
            Constants.Keys.UserId : uid,
            Constants.Keys.Name : fullname,
            Constants.Keys.About : about,
            Constants.Keys.Mode : mode == .Teach ? "Teach" : "Learn",
            Constants.Keys.MaximumDistance : maximumDistance,
            Constants.Keys.Latitude : getValueOrNull(latitude),
            Constants.Keys.Longitude : getValueOrNull(longitude),
            Constants.Keys.DiscoveryEnabled : discoveryEnabled,
            Constants.Keys.ImageUrl : getValueOrNull(image)
        ]
    }
    
}
