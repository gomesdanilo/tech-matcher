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
        performSegue(withIdentifier: Constants.SegueShowSettings, sender: self)
    }

    @IBAction func didClickOnMatchesButton(_ sender: Any) {
        performSegue(withIdentifier: "showMatches", sender: self)
    }
    
    @IBAction func didClickOnSkip(_ sender: Any) {
        datasource?.likeUser(userId: presentingUser!.uid, like: false, completionBlock: {
            self.retrieveNextUser()
        })
    }
    
    @IBAction func didClickOnConnect(_ sender: Any) {
        
        datasource?.likeUser(userId: presentingUser!.uid, like: true, completionBlock: { 
            self.retrieveNextUser()
        })
    }
    
    func loadUser(_ user : TMUser){
        presentingUser = user
        fullnameLabel.text = user.fullname
        aboutLabel.text = user.about
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
    
    func checkFirstUse(){
        datasource?.checkFirstUse({ (isFirstUse, error) in
            if let isFirstUse = isFirstUse {
                if isFirstUse {
                    self.didClickOnSettingsButton(self)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.SegueShowSettings == segue.identifier {
            let vc = segue.destination as! SettingsViewController
            vc.loggedInUserId = loggedInUserId
        }
    }
}
