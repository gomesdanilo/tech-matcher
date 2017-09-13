//
//  TMMessage.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 13/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

struct TMMessage {
    
    let content : String
    let user : String
    let date : String
    let isOtherUser : Bool
    
    fileprivate static let dateFormatter = { () -> DateFormatter in
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        return formatter
    }()
    
    
    fileprivate static func getTimestampText(_ timestampMS : Double) -> String {
        let seconds = timestampMS / 1000.0
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        return TMMessage.dateFormatter.string(from: date)
    }
    
    init?(currentUser: String, dictionary: [String:Any]){
        
        guard let content = dictionary["content"] as? String else {
            return nil
        }
        
        guard let user = dictionary["user"] as? String else {
            return nil
        }
        
        guard let date = dictionary["timestamp"] as? Double else {
            return nil
        }
        
        
        self.content = content
        self.user = user
        self.date = TMMessage.getTimestampText(date)
        self.isOtherUser = currentUser == user
    }
}
