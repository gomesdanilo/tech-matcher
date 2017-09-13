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
    let userId : String
    let date : String
    let isOtherUser : Bool
    var username : String?
    
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
    
    init?(currentUserId: String, dictionary: [String:Any]){
        
        guard let content = dictionary[Constants.Keys.Content] as? String else {
            return nil
        }
        
        guard let userId = dictionary[Constants.Keys.UserId] as? String else {
            return nil
        }
        
        guard let date = dictionary[Constants.Keys.Timestamp] as? Double else {
            return nil
        }
        
        
        self.content = content
        self.userId = userId
        self.date = TMMessage.getTimestampText(date)
        self.isOtherUser = currentUserId != userId
    }
}
