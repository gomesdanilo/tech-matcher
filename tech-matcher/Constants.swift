//
//  Constants.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 12/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit


enum SearchMode {
    case Teach
    case Learn
}

func searchModeFromString(_ string : String?) -> SearchMode {
    return string != nil && string == "Teach" ? SearchMode.Teach : SearchMode.Learn
}

struct Constants {
    
    static let SegueShowFinder = "showFinder"
    static let SegueShowSettings = "showSettings"
    static let SegueShowMatches = "showMatches"
    static let SegueShowChat = "showChat"
    
    static let MinimumTextFieldCharacters = 3
    static let ImageSize = 600
    static let JPEGCompression : CGFloat = 0.8
    
    struct Keys {
        
        // User
        static let UserId = "userId"
        static let Name = "name"
        static let About = "about"
        static let ImageUrl = "imageUrl"
        
        // Match
        static let MatchId = "matchId"
        
        // Message
        static let Content = "content"
        static let Timestamp = "timestamp"
    }
    
    
    
}