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
    
    
    var currentUser : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}
