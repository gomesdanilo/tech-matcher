//
//  SettingsViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var discoveryEnabledSwitch: UISwitch!
    @IBOutlet weak var maximumDistanceSlider: UISlider!
    @IBOutlet weak var teachOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var learnFromOtherPeopleCell: UITableViewCell!
    @IBOutlet weak var configureTopicsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSettingsData()
    }
    
    func loadSettingsData(){
    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == configureTopicsCell {
            print("clicked on configure topics")
        } else if cell == logoutCell {
            print("clicked on logout cell")
        }
        
    }

}
