//
//  ChatStorage.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatStorage: NSObject {

    private let node = "chat"
    
    var databaseReference: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    func configureDatabase() {
        databaseReference = Database.database().reference()
        
        // listen for new messages in the firebase database
        databaseHandle = databaseReference.child(node).observe(.childAdded) { (snapshot: DataSnapshot)in
            
            
        }
    }
    
    deinit {
        databaseReference.child(node).removeObserver(withHandle: databaseHandle)
    }

    
}
