//
//  ChatViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var chatId : String?
    var uid : String?
    var data : [DataSnapshot]?

    var databaseReference: DatabaseReference!
    fileprivate var databaseHandle: DatabaseHandle!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        data = []
        configureDatabase()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    func configureDatabase() {
        databaseReference = Database.database().reference()
        
        // listen for new messages in the firebase database
        databaseHandle = getChatNode().observe(.childAdded) { (snapshot: DataSnapshot) in
            self.data?.append(snapshot)
            let rows = [IndexPath(row: self.data!.count-1, section: 0)]
            self.tableView.insertRows(at: rows, with: .automatic)
        }
    }
    
    func getChatNode() -> DatabaseReference {
        return databaseReference.child("messages").child(chatId!)
    }
    
    func sendMessage(_ message : String){
        
        let ref = getChatNode().childByAutoId()
        
        let timestamp = ServerValue.timestamp()
        let data : [String : Any] = ["content" : message,
                    "chat" : chatId!,
                    "user" : uid!,
                    "timestamp" : timestamp]
        ref.updateChildValues(data) { (error, databaseReference) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    @IBAction func didClickOnSend(_ sender : Any){
        sendMessage(messageField.text!)
        messageField.text = ""
    }
    
    deinit {
        getChatNode().removeObserver(withHandle: databaseHandle)
    }
}

extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatTableViewCell
        let row = self.data![indexPath.row].value as? [String : Any?]
        
        let timestamp = row?["timestamp"]
        
        cell.messageLabel?.text = row?["content"] as? String
        cell.userLabel?.text = row?["user"] as? String
        
        return cell
    }
}
