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
    
    enum ScreenMode {
        case Presenting
        case UsersNotFound
        case Empty
    }

    // MARK: UI
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var containerUsersNotFound: UIStackView!
    
    
    
    // MARK: DATA
    var datasource : TMDatasource?
    var loggedInUserId : String?
    var loggedInUser : TMUser?
    var presentingUser : TMUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateScreen(mode: .Empty)
        
        if let loggedInUserId = loggedInUserId {
            datasource = TMDatasource(currentUserId: loggedInUserId)
            datasource?.matchDelegate = self
            datasource?.retrieveMatches()
            
            retrieveDetailsAndUsers()
        } else {
            showErrorMessage("Invalid parameters for screen.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.SegueShowSettings == segue.identifier {
            let vc = segue.destination as! SettingsViewController
            vc.loggedInUserId = loggedInUserId
        } else if Constants.SegueShowMatches == segue.identifier {
            let vc = segue.destination as! MatchesViewController
            vc.loggedInUser = loggedInUser
        }
    }
    
    func retrieveDetailsAndUsers(){
        
        if loggedInUser == nil {
            loadUserDetails({ (success) in
                if success {
                    self.retrieveNextUser()
                } else {
                    self.updateScreen(mode: FinderViewController.ScreenMode.UsersNotFound)
                }
            })
        } else {
            retrieveNextUser()
        }
    }
}

// MARK: - EVENTS

extension FinderViewController {
    
    func navigateToMatches(){
        performSegue(withIdentifier: Constants.SegueShowMatches, sender: self)
    }
    
    func navigateToSettings(){
        
        performSegue(withIdentifier: Constants.SegueShowSettings, sender: self)
    }
    
    
    @IBAction func didClickOnSettingsButton(_ sender: Any) {
        navigateToSettings()
    }
    
    @IBAction func didClickOnMatchesButton(_ sender: Any) {
        navigateToMatches()
        
    }
    
    @IBAction func didClickOnSkip(_ sender: Any) {
        likeUser(like: false)
    }
    
    @IBAction func didClickOnConnect(_ sender: Any) {
        likeUser(like: true)
    }
    
    @IBAction func didClickOnSearchAgain(_ sender: Any) {
        
        retrieveDetailsAndUsers()
    }
    
    
}


// MARK: - ACTIONS

extension FinderViewController {
    
    func updateScreen(mode : ScreenMode){
        switch mode {
        case .Presenting:
            self.container.isHidden = false
            self.containerUsersNotFound.isHidden = true
        case .UsersNotFound:
            self.container.isHidden = true
            self.containerUsersNotFound.isHidden = false
        case .Empty :
            self.container.isHidden = true
            self.containerUsersNotFound.isHidden = true
        }
    }
    
    func likeUser(like : Bool){
        if let presentingUser = presentingUser {
            datasource?.likeUser(userId: presentingUser.userId, like: like, completionBlock: {
                self.retrieveNextUser()
            })
        }
    }
    
    func loadUser(_ user : TMUser){
        
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
        
        if let datasource = self.datasource {
        
            updateScreen(mode: .Empty)
            showProgressWithMessage(message: "Retriving users...")
            datasource.nextUser(completionBlock: { (user, error) in
                self.dismissProgress()
                
                if error != nil {
                    self.showErrorMessage(error!)
                    self.updateScreen(mode: .Empty)
                    return
                }
                
                if user != nil {
                    self.loadUser(user!)
                    self.updateScreen(mode: .Presenting)
                } else {
                    self.updateScreen(mode: .UsersNotFound)
                }
            })
        
        
        }
    }
    
    func loadUserDetails(_ completionBlock : @escaping (_ success : Bool) -> Void){
        
        if let datasource = self.datasource {
            showProgressWithMessage(message: "Retrieving user details...")
            datasource.loadUserDetails({ (user, error, showSettings) in
                self.dismissProgress()
                
                if error != nil {
                    self.showErrorMessage(error!)
                }
                
                if showSettings {
                    self.didClickOnSettingsButton(self)
                }
                
                if user != nil {
                    self.loggedInUser = user
                    completionBlock(true)
                } else {
                    completionBlock(false)
                }
            })
        }
    }
}



extension FinderViewController : TMDatasourceMatchDelegate {

    func didReceiveListMatches(_ matches: [TMMatch]?, _ error: String?) {
        
        // This runs in the "background", no need to show errors to user.
        guard let matches = matches else {
            return
        }
        
        let notSeen = matches.filter { (match) -> Bool in
            return !match.seen
        }
        
        if notSeen.count > 0 {
            showMessage("You've got \(notSeen.count) match(es)! Why don't you have a look", title: "Yeah!")
         
            notSeen.forEach({ (item) in
                datasource?.checkMatchAsSeen(match: item, completionBlock: { (success, error) in
                    if error != nil {
                        print(error!)
                    }
                })
            })
            
        }
        
        
    }


}
