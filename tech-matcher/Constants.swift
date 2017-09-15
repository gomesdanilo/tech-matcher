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
    
    static let Timeout : Double = 5 // Seconds
    
    static let SegueShowFinder = "showFinder"
    static let SegueShowSettings = "showSettings"
    static let SegueShowMatches = "showMatches"
    static let SegueShowChat = "showChat"
    
    static let MinimumTextFieldCharacters = 3
    static let ImageSize = 600
    static let JPEGCompression : CGFloat = 0.8
    
    static let ErrorDetailsNotFound = "Details not found. This might be your first time. Please fill all details."
    static let ErrorNoInternet = "Sorry, your device is not connected to the Internet."
    
    static let ErrorTimeout = "Sorry, timeout reached. There is no data or you have connectivity issues"
    
    struct Keys {
        
        // User
        static let UserId = "userId"
        static let Name = "name"
        static let About = "about"
        static let ImageUrl = "imageUrl"
        
        // Match
        static let MatchId = "matchId"
        static let Seen = "seen"
        
        // Message
        static let Content = "content"
        static let Timestamp = "timestamp"
        
        
    }
    
    struct Entities {
        static let Users = "users"
    }
    
    
    
    
    
    
    
    
    
    
}
