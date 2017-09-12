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
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var databaseReference: DatabaseReference!
    fileprivate var databaseHandle: DatabaseHandle!
    
    var loggedInUser : TMUser?
    var presentingUser : TMUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        //checkFirstUse()
        retrieveNextUser()
    }
    
    @IBAction func didClickOnSettingsButton(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: self)
    }

    @IBAction func didClickOnMatchesButton(_ sender: Any) {
        performSegue(withIdentifier: "showMatches", sender: self)
    }
    
    @IBAction func didClickOnSkip(_ sender: Any) {
        retrieveNextUser()
    }
    
    @IBAction func didClickOnConnect(_ sender: Any) {
        retrieveNextUser()
    }
    
    func loadUser(_ user : TMUser){
        fullnameLabel.text = user.fullname
        aboutLabel.text = user.about
    }
    
    func retrieveNextUser(){
        
        // TODO: Validate if there is a match or not.
        // Skip users that have already been liked/disliked.
        // Skip same user as logged in
        
        databaseReference.child("users").queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            
            guard let user = TMUser(snapshot: snapshot) else {
                // Error
                return
            }
            
            self.loadUser(user)
            
        }) { (error) in
            print(error)
        }
    }
    
//    func checkFirstUse(){
//        
//        let userId = currentUser.uid
//        databaseReference.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let user = TMUser(snapshot: snapshot) {
//                print(user)
//                self.currentUserData = user
//            } else {
//                self.currentUserData = nil
//                self.didClickOnSettingsButton(self)
//            }
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    
    
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
//            let vc = segue.destination as! SettingsViewController
//            vc.uid = self.currentUser!.uid
//            vc.user = self.currentUserData
        }
    }
}
