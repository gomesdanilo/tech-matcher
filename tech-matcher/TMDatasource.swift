//
//  TMDatasource.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 12/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol TMDatasourceMatchDelegate {
    func didReceiveListMatches(_ matches : [TMMatch]?, _ error : String?)
}

protocol TMDatasourceMessageDelegate {
    func didReceiveListMessages(_ matches : [TMMessage]?, _ error : String?)
}

class TMDatasource {
    
    typealias UserFoundBlock = (_ user : TMUser?, _ error : String?) -> Void
    
    fileprivate var currentUserId : String
    fileprivate var databaseReference: DatabaseReference!
    fileprivate var databaseHandles : [DatabaseHandle] = []
    fileprivate var startingValue : String?
    fileprivate var storageReference: StorageReference!
    fileprivate var storageHandle : StorageHandle?
    fileprivate var dataHandled = false
    fileprivate var cacheUsers : [TMUser] =  []
    
    
    var matchDelegate : TMDatasourceMatchDelegate?
    var messageDelegate : TMDatasourceMessageDelegate?
    
    init(currentUserId : String) {
        databaseReference = Database.database().reference()
        storageReference = Storage.storage().reference()
        self.currentUserId = currentUserId
        
    }
    
    
    func isConnected() -> Bool {
        return ConnectivityHandler.sharedInstance().connected
    }
    
    
    deinit {
       databaseReference.removeAllObservers()
    }
}

// MARK: - User Details

extension TMDatasource {
    
    func loadUserDetails(_ completionBlock : @escaping (_ user : TMUser?,_ error : String?) -> Void){
        
        if !isConnected() {
            completionBlock(nil, "Sorry, your device is not connected to the Internet.")
            return
        }
        
        var responded = false
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timeout) {
            
            if !responded {
                responded = true
                completionBlock(nil, Constants.ErrorTimeout)
                return
            }
        }
        
        databaseReference
            .child(Constants.Entities.Users)
            .child(currentUserId)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                if !responded {
                    responded = true
                
                    guard let user = TMUser(snapshot: snapshot) else {
                        
                        completionBlock(nil, Constants.ErrorDetailsNotFound)
                        return
                    }
                    completionBlock(user, nil)
                
                }
            
        }) { (error) in
            
            if !responded {
                responded = true
                completionBlock(nil, error.localizedDescription)
                
            }
        }
    }
    
    func updateUserSettings(_ user : TMUser, completionBlock : @escaping (_ success : Bool, _ error : String?) -> Void){
        let userNode = databaseReference.child("users").child(user.userId)
        
        userNode.updateChildValues(user.json()) { (error, databaseReference) in
            
            guard error == nil else {
                completionBlock(false, error!.localizedDescription)
                return
            }
            
            completionBlock(true, nil)
        }
    }
    
    func savePicture(_ data : Data, completionBlock : @escaping (_ imageUrl : String?, _ error : String?) -> Void){
        let path = "user/\(currentUserId)/image.jpg"
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageReference.child(path).putData(data, metadata: metadata) { (metadata, error) in
            if error != nil {
                completionBlock(nil, error!.localizedDescription)
            } else {
                let url = self.storageReference!.child(metadata!.path!).description
                completionBlock(url, nil)
            }
        }
        
    }

    func downloadPicture(url : String, completionBlock : @escaping (_ data : Data?, _ error : String?) -> Void){
        Storage.storage().reference(forURL: url).getData(maxSize: INT64_MAX, completion: { (data, error) in
            
            completionBlock(data, error != nil ? error!.localizedDescription : nil)
        })
        
    }
}

// MARK: - Finder

extension TMDatasource {
    
    func likeUser(userId : String, like : Bool, completionBlock : @escaping () -> Void){
        
        let values = ["/userLikes/\(currentUserId)/\(userId)": like]
        
        // Updates database.
        databaseReference.updateChildValues(values) { (error, databaseReference) in
            completionBlock()
        }
    }
    
    func retrievePage(completionBlock : @escaping (_ users : [TMUser]?, _ error : String?) -> Void){
        
        if !isConnected() {
            completionBlock(nil, Constants.ErrorNoInternet)
            return
        }
        
        
        var query = databaseReference.child("users").queryOrderedByKey()
        
        if startingValue != nil {
            query = query.queryStarting(atValue: startingValue)
        }
        
        query.queryLimited(toFirst: 31).observeSingleEvent(of: .value, with:{ (snapshot) in
            
            if let values = snapshot.value as? [String : [String : Any]] {
                
                
                // Populates cache.
                var users : [TMUser] = []
                values.forEach({ (key, value) in
                    
                    // Skips first
                    if key == self.startingValue {
                        return
                    }
                    
                    // Skips this user
                    if self.currentUserId == key {
                        return
                    }
                    
                    if let user = TMUser(userId: key, dictionary: value) {
                        users.append(user)
                    }
                })
                
                // Sorts results.
                users.sort(by: { (userA, userB) -> Bool in
                    return userA.userId.compare(userB.userId) == ComparisonResult.orderedAscending
                })
                
                // Saves pagination value.
                if users.count > 0 {
                    self.startingValue = users[users.count - 1].userId
                    completionBlock(users, nil)
                } else {
                    self.startingValue = nil
                    completionBlock(nil, "No records found")
                }
                
                
            } else {
                
                // Error
                completionBlock(nil, "Failed to retrieve data")
            }
        })
    }
    
    /**
     Internally, it retrieves the next 30 items and stores it on the cache. Then when
     the cache is reached, retrieves another page.
     */
    func nextUser(completionBlock : @escaping UserFoundBlock){
        
        if cacheUsers.count > 0 {
            // User found
            completionBlock(self.cacheUsers.remove(at: 0), nil)
            return
        }
        
        if !isConnected() {
            completionBlock(nil, Constants.ErrorNoInternet)
            return
        }
        
        retrievePage { (usersRetrieved, error) in
            
            if let usersRetrieved = usersRetrieved {
                
                // Check if the users in the list were liked before.
                let path = "/userLikes/\(self.currentUserId)"
                self.databaseReference.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    
                    
                    if let likedPreviously = snapshot.value as? [String : Bool] {
                        // User has likes
                        self.cacheUsers = []
                        
                        for user in usersRetrieved {
                            
                            if likedPreviously[user.userId] == nil {
                                // Not seen
                                self.cacheUsers.append(user)
                            }
                        }
                    } else {
                        // User has no likes
                        self.cacheUsers = usersRetrieved
                    }
                    
                    if self.cacheUsers.count > 0 {
                        // User found
                        completionBlock(self.cacheUsers.remove(at: 0), nil)
                    } else {
                        // Users not found
                        completionBlock(nil, nil)
                    }
                })
            } else {
                // Users not found
                completionBlock(nil, nil)
            }
        }
    }
    
}

// MARK: - Matches screen

extension TMDatasource {
    
    func parseMatch(_ userMatchSnapshot : DataSnapshot, _ userSnapshot  : DataSnapshot) -> TMMatch? {
        
        guard let matchDictionary = userMatchSnapshot.value as? [String: Any] else {
            return nil
        }
        
        guard let userDictionary = userSnapshot.value as? [String: Any] else {
            return nil
        }
        
        guard let user = TMUser(userId: userSnapshot.key, dictionary: userDictionary) else {
            return nil
        }
        
        guard let match = TMMatch(match: matchDictionary, user : user) else {
            return nil
        }
        
        // Ignores same user
        if self.currentUserId == user.userId {
            return nil
        }
        return match
    }
    
    func checkMatchAsSeen(match : TMMatch,
                          completionBlock : @escaping (_ success : Bool, _ error : String?) -> Void){
        
        let path = "usersMatches/\(self.currentUserId)/\(match.user.userId)"
        let ref =  self.databaseReference.child(path)
        let data : [String : Any] = [Constants.Keys.Seen : true]
        
        ref.updateChildValues(data) { (error, databaseReference) in
            if error != nil {
                completionBlock(false, error!.localizedDescription)
                return
            }
            completionBlock(true, nil)
        }
    }

    func retrieveMatches(){
        
        if !isConnected() {
            self.matchDelegate?.didReceiveListMatches(nil, Constants.ErrorNoInternet)
        }
        
        var responded = false
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timeout) {
            
            if !responded {
                responded = true
                self.matchDelegate?.didReceiveListMatches(nil, Constants.ErrorTimeout)
                return
            }
        }
        
        // TODO: Release handle
        self.databaseReference
            .child("usersMatches/\(self.currentUserId)")
            .queryOrderedByKey()
            .observe(.childAdded, with: { (userMatchSnapshot) in
                
                self.databaseReference
                    .child("/users/\(userMatchSnapshot.key)")
                    .observeSingleEvent(of: .value, with: { (userSnapshot) in
                        
                        responded = true
                        
                        guard let match = self.parseMatch(userMatchSnapshot, userSnapshot) else {
                            self.matchDelegate?.didReceiveListMatches(nil, "Invalid response from server")
                            return
                        }
                        
                        self.matchDelegate?.didReceiveListMatches([match], nil)
                    })
                
            })
    }
}


// MARK: - Messages Screen
extension TMDatasource {
    
    func retrieveMessages(matchId : String){
        
        if !isConnected(){
            self.messageDelegate?.didReceiveListMessages(nil, Constants.ErrorNoInternet)
        }
        
        var responded = false
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timeout) {
            
            if !responded {
                responded = true
                self.matchDelegate?.didReceiveListMatches(nil, Constants.ErrorTimeout)
                return
            }
        }
        
        // TODO: Release handle
        self.databaseReference
            .child("chat/\(matchId)")
            .queryOrderedByKey()
            .observe(.childAdded, with: { (message) in
                
                responded = true
                
                guard let dictionary = message.value as? [String: Any] else {
                    self.messageDelegate?.didReceiveListMessages(nil, "Invalid response from server")
                    return
                }
                
                guard let message = TMMessage(currentUserId: self.currentUserId, dictionary: dictionary) else {
                    self.messageDelegate?.didReceiveListMessages(nil, "Invalid response from server")
                    return
                }
                
                self.messageDelegate?.didReceiveListMessages([message], nil)
            })
    }
    
    func sendMessage(_ message : String, matchId : String, completionBlock : @escaping (_ success : Bool, _ error : String?) -> Void){
        
        if !isConnected() {
            completionBlock(false, Constants.ErrorNoInternet)
            return
        }
        
        let ref =  self.databaseReference.child("chat/\(matchId)").childByAutoId()
        let timestamp = ServerValue.timestamp()
        
        let data : [String : Any] = [Constants.Keys.Content : message,
                                     Constants.Keys.MatchId : matchId,
                                     Constants.Keys.UserId : self.currentUserId,
                                     Constants.Keys.Timestamp : timestamp]
        
        ref.updateChildValues(data) { (error, databaseReference) in
            if error != nil {
                completionBlock(false, error!.localizedDescription)
                return
            }
            completionBlock(true, nil)
            
        }
    }
}
