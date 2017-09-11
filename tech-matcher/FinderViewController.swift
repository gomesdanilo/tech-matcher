//
//  FinderViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class FinderViewController: UIViewController {

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var aboutTextView: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var databaseReference: DatabaseReference!
    fileprivate var databaseHandle: DatabaseHandle!
    
    var currentUser : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
    }
    
    @IBAction func didClickOnSettingsButton(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: self)
    }

    @IBAction func didClickOnMatchesButton(_ sender: Any) {
        performSegue(withIdentifier: "showMatches", sender: self)
    }
    
    @IBAction func didClickOnSkip(_ sender: Any) {
    
    }
    
    @IBAction func didClickOnConnect(_ sender: Any) {
        
    }
    
    
    
    func configureDatabase() {
        databaseReference = Database.database().reference()
        
        // listen for new messages in the firebase database
        databaseHandle = databaseReference.child("messages").observe(.childAdded) { (snapshot: DataSnapshot)in

            
            
//            let data = [Constants.MessageFields.text: textField.text! as String]
//            sendMessage(data: data)
//            
//            var mdata = data
//            // add name to message and then data to firebase database
//            mdata[Constants.MessageFields.name] = displayName
//            ref.child("messages").childByAutoId().setValue(mdata)
            
        }
    }
    
    deinit {
        databaseReference.child("messages").removeObserver(withHandle: databaseHandle)
    }
}
