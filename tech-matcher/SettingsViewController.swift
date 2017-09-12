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

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var discoveryEnabledSwitch: UISwitch!
    @IBOutlet weak var maximumDistanceSlider: UISlider!
    @IBOutlet weak var teachOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var learnFromOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var configureTopicsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var maximumDistanceLabel: UILabel!
    
    var loggedInUserId : String?
    var datasource : FinderDatasource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = FinderDatasource(currentUserId: loggedInUserId!)
        populateScreenWithEmptyValues()
        loadSettingsData()
    }
    
    
    func populateScreenWithEmptyValues(){
        nameTextfield.text = ""
        aboutTextView.text = ""
        discoveryEnabledSwitch.isOn = true
        maximumDistanceSlider.value = 15
        teachOtherPeopleCell.accessoryType = .none
        learnFromOtherPeopleCell.accessoryType = .checkmark
        didChangeMaximumDistance(maximumDistanceSlider)
    }
    
    func populateScreenWithUser(_ user : TMUser){
        nameTextfield.text = user.fullname
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
        didChangeMaximumDistance(maximumDistanceSlider)
    }
    
    func loadSettingsData(){
        
        datasource?.loadUserDetails({ (user, error) in
            guard error == nil else {
                self.showErrorMessage(error!)
                self.showErrorMessage("This is your first use of the app, please fill all fields.")
                return
            }
            
            guard let user = user else {
                self.showErrorMessage("Invalid user")
                self.showErrorMessage("This is your first use of the app, please fill all fields.")
                return
            }
            
            self.populateScreenWithUser(user)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    func validateScreen() -> Bool {
    
        if nameTextfield!.text!.characters.count <= 3 {
            showErrorMessage("Field name is mandatory")
            return false
        }
        
        if aboutTextView!.text!.characters.count <= 3 {
            showErrorMessage("Field about is mandatory")
            return false
        }
        
        return true
    }
    
    func createUserUpdate() -> TMUser{
        
        let mode = teachOtherPeopleCell.accessoryType == .checkmark ? TMUser.Mode.Teach : TMUser.Mode.Learn
        
        return TMUser(uid: loggedInUserId!,
                      fullname: nameTextfield!.text!,
                      about: aboutTextView!.text!,
                      mode: mode,
                      maximumDistance: Int(maximumDistanceSlider.value),
                      discoveryEnabled: discoveryEnabledSwitch.isOn,
                      latitude: nil, longitude: nil)
    }
    
    func saveSettings(){
        
        if !validateScreen(){
            return
        }
        
        let user = createUserUpdate()
        
        datasource?.updateUserSettings(user, completionBlock: { (success, errorMessage) in
            guard errorMessage == nil else {
                self.showErrorMessage(errorMessage!)
                return
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == teachOtherPeopleCell {
            teachOtherPeopleCell.accessoryType = .checkmark
            learnFromOtherPeopleCell.accessoryType = .none
        } else if cell == learnFromOtherPeopleCell {
            teachOtherPeopleCell.accessoryType = .none
            learnFromOtherPeopleCell.accessoryType = .checkmark
        }
        else if cell == configureTopicsCell {
            showErrorNotImplemented()
        } else if cell == logoutCell {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func didChangeMaximumDistance(_ sender: Any) {
        maximumDistanceLabel.text =  "\(Int(maximumDistanceSlider.value)) km"
    }
}
