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

    let userId : String
    let fullname : String
    let about : String
    let image : String?
    
    init(   userId : String,
            fullname : String,
            about : String,
            image : String?){
        
        self.userId = userId
        self.fullname = fullname
        self.about = about
        self.image = image
    }

    init?(snapshot : DataSnapshot) {
        guard let dictionary = snapshot.value as? [String : Any?] else {
            return nil
        }
        self.init(userId: snapshot.key, dictionary: dictionary)
    }
    
    
    init?(userId : String, dictionary : [String: Any?]) {
        
        guard let fullname = dictionary[Constants.Keys.Name] as? String else {
            return nil
        }
        
        guard let about = dictionary[Constants.Keys.About] as? String else {
            return nil
        }
        
        self.userId = userId
        self.fullname = fullname
        self.about = about
        self.image = dictionary[Constants.Keys.ImageUrl] as? String
    }
    
    
    func getValueOrNull(_ value : Any?) -> Any{
        return value != nil ? value! : NSNull()
    }
    
    func json() -> [String: Any]{
        return [
            Constants.Keys.UserId : userId,
            Constants.Keys.Name : fullname,
            Constants.Keys.About : about,
            Constants.Keys.ImageUrl : getValueOrNull(image)
        ]
    }
    
}
