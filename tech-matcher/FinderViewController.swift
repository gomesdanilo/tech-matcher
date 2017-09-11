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
    var currentUserData : TMUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        checkFirstUse()
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
    
    
    func checkFirstUse(){
        
        let userId = currentUser.uid
        databaseReference.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let user = TMUser(snapshot: snapshot) {
                print(user)
                self.currentUserData = user
            } else {
                self.currentUserData = nil
                self.didClickOnSettingsButton(self)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "showSettings" == segue.identifier {
            let vc = segue.destination as! SettingsViewController
            vc.firebaseUser = self.currentUser
            vc.user = self.currentUserData
        }
    }
}
