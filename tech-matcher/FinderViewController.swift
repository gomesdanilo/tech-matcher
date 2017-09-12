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
    
    var datasource : FinderDatasource?
    
    var loggedInUserId : String?
    var presentingUser : TMUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = FinderDatasource(currentUserId: loggedInUserId!)
        //configureDatabase()
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
        presentingUser = user
        fullnameLabel.text = user.fullname
        aboutLabel.text = user.about
    }
    
    func showErrorMessage(_ message : String){
        print("error", message)
    }
    
    func retrieveNextUser(){
        
        datasource?.nextUser(completionBlock: { (user, error) in
            if error != nil {
                self.showErrorMessage(error!)
                return
            }
            
            if user != nil {
                self.loadUser(user!)
            }
        })
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
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "showSettings" == segue.identifier {
//            let vc = segue.destination as! SettingsViewController
//            vc.uid = self.currentUser!.uid
//            vc.user = self.currentUserData
        }
    }
}
