//
//  MatchesViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MatchesViewController: UITableViewController {

    
    var uid : String?
    var selectedChatId : String?
    var matches : [DataSnapshot] = []
    var databaseReference: DatabaseReference!
    fileprivate var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
    }
    
    func configureDatabase() {
        databaseReference = Database.database().reference()
        
        // listen for new messages in the firebase database
        databaseHandle = getMatchesNode().observe(.childAdded) { (snapshot: DataSnapshot) in
            self.matches.append(snapshot)
            let rows = [IndexPath(row: self.matches.count-1, section: 0)]
            self.tableView.insertRows(at: rows, with: .automatic)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MatchesTableViewCell
        let row = matches[indexPath.row]
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showChat", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "showChat" == segue.identifier {
            let vc = segue.destination as! ChatViewController
            vc.chatId = chatId
            vc.uid = uid
        }
    }
    
    func getMatchesNode() -> DatabaseReference {
        return databaseReference.child("matches").child(uid!)
    }
    
    deinit {
        getMatchesNode().removeObserver(withHandle: databaseHandle)
    }
}
