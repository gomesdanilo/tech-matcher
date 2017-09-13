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
    var loggedInUser : TMUser?
    var datasource : TMDatasource?
    var matches : [TMMatch] = []
    var selectedMatch : TMMatch?
    var imageCache = NSCache<NSString, UIImage>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = TMDatasource(currentUserId: loggedInUser!.userId)
        datasource?.matchDelegate = self
        datasource?.retrieveMatches()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.SegueShowChat == segue.identifier {
            let vc = segue.destination as! ChatViewController
            vc.loggedInUser = loggedInUser!
            vc.match = self.selectedMatch!
        }
    }
    
    func handlePicturesForCell(_ cell : MatchesTableViewCell,
                               indexPath : IndexPath,
                               data: TMMatch) {
        
        if let url = data.user.image {
        
            if let image = imageCache.object(forKey: url as NSString) {
                cell.avatarImageView.image = image
            } else {
                
                datasource?.downloadPicture(url: url, completionBlock: { (data, error) in
                    if let data = data {
                        if let image = UIImage(data: data) {
                            self.imageCache.setObject(image, forKey: url as NSString)
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
                
            }
        } else {
            cell.avatarImageView.image = #imageLiteral(resourceName: "match-placeholder")
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
        handlePicturesForCell(cell, indexPath: indexPath, data: row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = matches[indexPath.row]
        navigateToChat(row)
    }

}

// MARK: - TMDatasourceDelegate
extension MatchesViewController : TMDatasourceMatchDelegate {

    func didReceiveListMatches(_ matches: [TMMatch]?, _ error: String?) {
        
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
    
    func navigateToChat(_ match : TMMatch){
        self.selectedMatch = match
        self.performSegue(withIdentifier: Constants.SegueShowChat, sender: self)
    }
}
