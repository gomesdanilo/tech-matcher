//
//  SettingsViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class SettingsViewController: UITableViewController {

    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var discoveryEnabledSwitch: UISwitch!
    @IBOutlet weak var maximumDistanceSlider: UISlider!
    @IBOutlet weak var teachOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var learnFromOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var configureTopicsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    var firebaseUser : User?
    var user : TMUser?
    
    var databaseReference: DatabaseReference!
    fileprivate var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        loadSettingsData()
    }
    
    func loadSettingsData(){
    
        if let user = user {
            aboutTextView.text = user.about
            discoveryEnabledSwitch.isOn = user.discoveryEnabled
            maximumDistanceSlider.value = Float(user.maximumDistance)
            
            if user.mode == .Teach {
                teachOtherPeopleCell.accessoryType = .checkmark
                learnFromOtherPeopleCell.accessoryType = .none
            } else {
                teachOtherPeopleCell.accessoryType = .none
                learnFromOtherPeopleCell.accessoryType = .checkmark
            }
            
        } else {
            showErrorMessage("This is your first use of the app, please fill all fields.")
            
            aboutTextView.text = ""
            discoveryEnabledSwitch.isOn = true
            maximumDistanceSlider.value = 15
            teachOtherPeopleCell.accessoryType = .none
            learnFromOtherPeopleCell.accessoryType = .checkmark
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    func updateUser() -> TMUser {
        
        var json = []
        
        
        
        var user = TMUser()
        
        user.fullname = "Sample Name"
        user.about = aboutTextView.text
        user.mode = teachOtherPeopleCell.accessoryType == UITableViewCellAccessoryType.checkmark ? TMUser.Mode.Teach : TMUser.Mode.Learn
        user.maximumDistance = Int(maximumDistanceSlider.value)
        user.discoveryEnabled = discoveryEnabledSwitch.isOn
        user.latitude = nil
        user.longitude = nil
        
        
        return user
        
    }
    
    func saveSettings(){
        let user = updateUser()
        let json = user.json()
        
        let userNode = databaseReference.child("users").child(firebaseUser!.uid)
        userNode.updateChildValues(json) { (error, databaseReference) in
        
            guard error == nil else {
                print(error!)
                return
            }
        }
    }
    
    func showErrorMessage(_ message : String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == configureTopicsCell {
            print("clicked on configure topics")
        } else if cell == logoutCell {
            print("clicked on logout cell")
        }
        
    }
    
    func configureDatabase() {
        databaseReference = Database.database().reference()
    }
    
    deinit {
        //databaseReference.child("messages").removeObserver(withHandle: databaseHandle)
    }

}
