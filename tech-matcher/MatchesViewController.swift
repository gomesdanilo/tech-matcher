//
//  MatchesViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class MatchesViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MatchesTableViewCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showChat", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "showChat" == segue.identifier {
            let vc = segue.destination as! ChatViewController
            vc.chatId = "chat01"
            vc.uid = "user01"
        }
    }
    
}
