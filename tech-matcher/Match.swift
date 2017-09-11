//
//  Match.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import FirebaseDatabase


struct Match {
    
    let users : [String: String]
    
    init?(currentUserUid: String, snapshot : DataSnapshot) {
        
        
        guard let dictionary = snapshot.value as? [String : Any?] else {
            return nil
        }
        
        var list : [String:String] = [:]
        
        
        
        
        
        users = list
        
    }
}
