//
//  Match.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import FirebaseDatabase


struct TMMatch {
    
    let name : String
    let match : String
    
    init?(match: [String: Any], user : [String: Any]) {
        
        guard let name = user["fullname"] as? String else {
            return nil
        }
        
        guard let match = match["match"] as? String else {
            return nil
        }
        
        self.match = match
        self.name = name
    }
}
