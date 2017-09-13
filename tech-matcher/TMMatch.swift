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
    let seen : Bool
    
    init?(match: [String: Any], user : TMUser) {
        
        guard let matchId = match[Constants.Keys.MatchId] as? String else {
            return nil
        }
        
        guard let seen = match[Constants.Keys.Seen] as? Bool else {
            return nil
        }
        
        self.matchId = matchId
        self.user = user
        self.seen = seen
    }
}
