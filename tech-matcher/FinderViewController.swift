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

    // MARK: UI
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var container: UIStackView!
    
    // MARK: DATA
    var datasource : TMDatasource?
    var loggedInUserId : String?
    var loggedInUser : TMUser?
    var presentingUser : TMUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = TMDatasource(currentUserId: loggedInUserId!)
        loadUserDetails()
        self.container.isHidden = true
        retrieveNextUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.SegueShowSettings == segue.identifier {
            let vc = segue.destination as! SettingsViewController
            vc.loggedInUserId = loggedInUserId
        } else if Constants.SegueShowMatches == segue.identifier {
            let vc = segue.destination as! MatchesViewController
            vc.loggedInUser = loggedInUser!
        }
    }
}

// MARK: - EVENTS

extension FinderViewController {
    @IBAction func didClickOnSettingsButton(_ sender: Any) {
        performSegue(withIdentifier: Constants.SegueShowSettings, sender: self)
    }
    
    @IBAction func didClickOnMatchesButton(_ sender: Any) {
        performSegue(withIdentifier: Constants.SegueShowMatches, sender: self)
    }
    
    @IBAction func didClickOnSkip(_ sender: Any) {
        likeUser(like: false)
    }
    
    @IBAction func didClickOnConnect(_ sender: Any) {
        likeUser(like: true)
    }
}


// MARK: - ACTIONS

extension FinderViewController {
    func likeUser(like : Bool){
        if let presentingUser = presentingUser {
            datasource?.likeUser(userId: presentingUser.userId, like: like, completionBlock: {
                self.retrieveNextUser()
            })
        }
    }
    
    func loadUser(_ user : TMUser){
        
        container.isHidden = false
        
        presentingUser = user
        fullnameLabel.text = user.fullname
        aboutLabel.text = user.about
        
        avatarImageView.image = #imageLiteral(resourceName: "avatar-finder-placeholder")
        if let image = user.image {
            datasource?.downloadPicture(url: image, completionBlock: { (data, error) in
                
                if let data = data {
                    if let img = UIImage(data: data) {
                        self.avatarImageView.image = img
                        return
                    }
                }
            })
        }
    }
    
    func retrieveNextUser(){
        showProgressWithMessage(message: "Retrieving users...")
        datasource?.nextUser(completionBlock: { (user, error) in
            self.dismissProgress()
            if error != nil {
                self.showErrorMessage(error!)
                return
            }
            
            if user != nil {
                self.loadUser(user!)
            } else {
                self.container.isHidden = true
            }
        })
    }
    
    func loadUserDetails(){
        datasource?.loadUserDetails({ (user, error) in
            
            if user == nil {
                self.didClickOnSettingsButton(self)
            } else {
                self.loggedInUser = user
            }
        })
    }
}
