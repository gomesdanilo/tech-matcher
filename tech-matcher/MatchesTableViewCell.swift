//
//  MatchesTableViewCell.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit


class MatchesTableViewCell: UITableViewCell {

    // MARK: UI
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.setBorder(width: 1, color: UIColor.gray)
        self.avatarImageView.setRound(cornerRadius: 30)
    }
    
    func populateWithMatch(_ match : Match){
        self.lastMessageLabel.text = ""
        self.usernameLabel.text = match.name
    }
    
}
