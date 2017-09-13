//
//  Match.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import FirebaseDatabase


struct TMMatch {
    
    let matchId : String
    let user : TMUser
    
    init?(match: [String: Any], user : TMUser) {
        
        guard let matchId = match[Constants.Keys.MatchId] as? String else {
            return nil
        }
        
        self.matchId = matchId
        self.user = user
    }
}
