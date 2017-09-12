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

    enum Mode {
        case Teach
        case Learn
    }
    
    let uid : String
    let fullname : String
    let about : String
    let mode : Mode
    let maximumDistance : Int
    let discoveryEnabled : Bool
    
    let latitude : Double?
    let longitude : Double?
    
    let image : String?
    
    init(   uid : String,
            fullname : String,
            about : String,
            mode : Mode,
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
        
        guard let fullname = dictionary["fullname"] as? String else {
            return nil
        }
        
        guard let about = dictionary["about"] as? String else {
            return nil
        }
        
        guard let mode = dictionary["mode"] as? String else {
            return nil
        }
        
        guard let maximumDistance = dictionary["maximumDistance"] as? Int else {
            return nil
        }
        
        guard let discoveryEnabled = dictionary["discoveryEnabled"] as? Bool else {
            return nil
        }
        
        self.uid = uid
        self.fullname = fullname
        self.about = about
        self.mode = mode == "Teach" ? Mode.Teach : Mode.Learn
        self.maximumDistance = maximumDistance
        self.discoveryEnabled = discoveryEnabled
        
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        image = dictionary["image"] as? String
    }
    
    
    func getValueOrNull(_ value : Any?) -> Any{
        return value != nil ? value! : NSNull()
    }
    
    func json() -> [String: Any]{
        return [
            "uid" : uid,
            "fullname" : fullname,
            "about" : about,
            "mode" : mode == .Teach ? "Teach" : "Learn",
            "maximumDistance" : maximumDistance,
            "latitude" : getValueOrNull(latitude),
            "longitude" : getValueOrNull(longitude),
            "discoveryEnabled" : discoveryEnabled,
            "image" : getValueOrNull(image)
        ]
    }
    
}
