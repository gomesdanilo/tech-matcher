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
    var loggedInUser : TMUser?
    var match : TMMatch?
    var datasource : TMDatasource?
    var keyboardController : KeyboardController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keyboardController = KeyboardController()
        self.keyboardController?.delegate = self
        self.keyboardController?.viewController = self
        self.keyboardController?.manageTextField(messageField)
        self.keyboardController?.addDimissView(self.tableView)
        
        self.navigationItem.title = match!.user.fullname
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.datasource = TMDatasource(currentUserId: loggedInUser!.userId)
        self.datasource?.messageDelegate = self
        self.datasource?.retrieveMessages(matchId: match!.matchId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardController?.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController?.unsubscribeToKeyboardNotifications()
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
        
        if message.characters.count == 0 {
            return
        }
        
        datasource?.sendMessage(message,
                                matchId: self.match!.matchId,
                                completionBlock: { (success, error) in
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

    func didReceiveListMessages(_ messages: [TMMessage]?, _ error: String?) {
        
        if error != nil {
            showErrorMessage(error!)
            return
        }
        
        if var messages = messages {
            
            // Updates user names
            for index in 0..<messages.count {
                messages[index].username = messages[index].userId == loggedInUser!.userId ? loggedInUser?.fullname : match!.user.fullname
            }
            
            self.messages.append(contentsOf: messages)
            let rows = [IndexPath(row: self.messages.count-1, section: 0)]
            self.tableView.insertRows(at: rows, with: .none)
            self.scrollToBottomMessage()
        }
    }

}

extension ChatViewController : KeyboardControllerDelegate {

    func keyboardControllerDidPressEnter(_ controller: KeyboardController) {
        didClickOnSend(self)
    }
}
