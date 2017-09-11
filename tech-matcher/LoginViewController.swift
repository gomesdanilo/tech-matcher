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

    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
    }
    
    func loginFlow(){
        let vc = FUIAuth.defaultAuthUI()!.authViewController()
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func didClickOnLogin(_ sender: Any) {
        loginFlow()
    }
    
    
    func configureAuth(){
        _authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            print("auth", auth)
            
            if let user = user {
                print("user", user)
            } else {
                self.loginFlow()
            }
            
        }
    }
    
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    

}
