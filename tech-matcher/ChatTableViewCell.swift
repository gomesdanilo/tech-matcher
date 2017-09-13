//
//  ChatTableViewCell.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    // MARK: UI
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func populateWithMessage(_ message: TMMessage){
        userLabel.text = message.username
        timestampLabel.text = message.date
        messageLabel.text = message.content
        
        if message.isOtherUser {
            userLabel.textAlignment = .right
            userLabel.textColor = UIColor.gray
        } else {
            userLabel.textAlignment = .left
            userLabel.textColor = UIColor.blue
        }
    }
}
