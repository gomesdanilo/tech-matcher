//
//  LoginViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class LoginViewController: UIViewController {

    fileprivate var authHandle: AuthStateDidChangeListenerHandle!
    var currentUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
    }
    
    func loginFlow(){
        let vc = FUIAuth.defaultAuthUI()!.authViewController()
        present(vc, animated: true, completion: nil)
    }
    
    func navigateToMainPage(user : User){
        self.currentUser = user
        self.performSegue(withIdentifier: "showFinder", sender: self)
    }
    
    @IBAction func didClickOnLogin(_ sender: Any) {
        loginFlow()
    }
    
    func configureAuth(){
        authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
                self.navigateToMainPage(user : user)
            } else {
                self.loginFlow()
            }
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(authHandle)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "showFinder" == segue.identifier {
            
            let vc = segue.destination as! FinderViewController
            //vc.currentUser = self.currentUser!
        }
    }

}
