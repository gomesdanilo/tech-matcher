//
//  MatchesViewController.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit


class MatchesViewController: UITableViewController {
    
    // MARK: Data
    var loggedInUserId : String?
    var datasource : FinderDatasource?
    var matches : [Match] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = FinderDatasource(currentUserId: loggedInUserId!)
        datasource?.delegate = self
        datasource?.retrieveMatches()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.SegueShowChat == segue.identifier {
            let vc = segue.destination as! ChatViewController
            //vc.loggedInUserId = loggedInUserId
            //vc.chatId = chatId
            //vc.uid = uid
        }
    }
}

extension MatchesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MatchesTableViewCell
        let row = matches[indexPath.row]
        cell.populateWithMatch(row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToChat()
    }

}

// MARK: - FinderDatasourceDelegate
extension MatchesViewController : FinderDatasourceDelegate {

    func didReceiveListMatches(_ matches: [Match]?, _ error: String?) {
        
        if error != nil {
            showErrorMessage(error!)
            return
        }
        
        if matches != nil {
            self.matches.append(contentsOf: matches!)
            self.tableView.reloadData()
        }
    }
}

// MARK: - Actions
extension MatchesViewController {
    
    func navigateToChat(){
        self.performSegue(withIdentifier: Constants.SegueShowChat, sender: self)
    }
}
