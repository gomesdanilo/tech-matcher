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
    
    // MARK: UI
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Data
    fileprivate var messages : [TMMessage] = []
    var loggedInUserId : String?
    var matchId : String? // Same as chatId
    var datasource : TMDatasource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.datasource = TMDatasource(currentUserId: loggedInUserId!)
        self.datasource?.messageDelegate = self
        self.datasource?.retrieveMessages(matchId: matchId!)
    }
    
}

// MARK: - Table
extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatTableViewCell
        let row = self.messages[indexPath.row]
        cell.populateWithMessage(row)
        return cell
    }
}

// MARK: - Actions

extension ChatViewController {

    func scrollToBottomMessage() {
        if messages.count == 0 {
            return
        }
        
        let bottomMessageIndex = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    func sendMessage(_ message : String){
        
        datasource?.sendMessage(message, matchId: self.matchId!, completionBlock: { (success, error) in
            if error != nil {
                self.showErrorMessage(error!)
                return
            }
        })
    }
}


// MARK: - Events

extension ChatViewController {

    @IBAction func didClickOnSend(_ sender : Any){
        sendMessage(messageField.text!)
        messageField.text = ""
    }
}

extension ChatViewController : TMDatasourceMessageDelegate {

    func didReceiveListMessages(_ matches: [TMMessage]?, _ error: String?) {
        
        if error != nil {
            showErrorMessage(error!)
            return
        }
        
        if let matches = matches {
            self.messages.append(contentsOf: matches)
            let rows = [IndexPath(row: self.messages.count-1, section: 0)]
            self.tableView.insertRows(at: rows, with: .none)
            self.scrollToBottomMessage()
        }
    }

}
