//
//  FinderDatasource.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 12/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class FinderDatasource {
    
    typealias UserFoundBlock = (_ user : TMUser?, _ error : String?) -> Void
    
    fileprivate var currentUserId : String
    fileprivate var databaseReference: DatabaseReference!
    fileprivate var databaseHandle : DatabaseHandle?
    fileprivate var startingValue : String?
    
    fileprivate var storageReference: StorageReference!
    fileprivate var storageHandle : StorageHandle?
    
    fileprivate var dataHandled = false
    
    fileprivate var cacheUsers : [TMUser] =  []
    
    init(currentUserId : String) {
        databaseReference = Database.database().reference()
        storageReference = Storage.storage().reference()
        self.currentUserId = currentUserId
    }
    
    func listenForMatches(){
        
        //databaseReference.child("/matches/\(currentUserId)")
         //   .queryEqual(toValue: false, childKey: "seenBy/\(currentUserId)")
        
        //databaseReference.child("/userLikedBy/\(currentUserId)").observe
        
    }
    
    func likeUser(userId : String, like : Bool, completionBlock : @escaping () -> Void){
        
        let values = [
            "/userLikedBy/\(userId)/\(currentUserId)": like,
            "/userLikes/\(currentUserId)/\(userId)": like,
        ]
        
        // Updates database.
        databaseReference.updateChildValues(values) { (error, databaseReference) in
            completionBlock()
        }
    }
    
    func listenForMathes(){
    
        
    }
    
    
    
    func retrievePage(completionBlock : @escaping (_ users : [TMUser]?, _ error : String?) -> Void){
        var query = databaseReference.child("users").queryOrderedByKey()
        
        if startingValue != nil {
            query = query.queryStarting(atValue: startingValue)
        }
        
        query.queryLimited(toFirst: 30).observeSingleEvent(of: .value, with:{ (snapshot) in
            
            if let values = snapshot.value as? [String : [String : Any]] {
                
                // Populates cache.
                var users : [TMUser] = []
                values.forEach({ (key, value) in
                    if let user = TMUser(uid: key, dictionary: value) {
                        users.append(user)
                    }
                })
                
                // Sorts results.
                users.sort(by: { (userA, userB) -> Bool in
                    return userA.uid.compare(userB.uid) == ComparisonResult.orderedAscending
                })
                
                // Saves pagination value.
                if users.count > 0 {
                    self.startingValue = users[users.count - 1].uid
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
            completionBlock(self.cacheUsers.remove(at: 0), nil)
            return
        }
        
        self.cacheUsers = []
        retrievePage { (users, error) in
            
            if let users = users {
            
                let path = "/userLikedBy/\(self.currentUserId)"
                self.databaseReference.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let list = snapshot.value as? [String : [String : Bool]] {
                        for user in users {
                        
                            if let item = list[user.uid] {
                                // Seen
                            } else {
                                // Not seen
                                self.cacheUsers.append(user)
                            }
                        }
                    } else {
                        self.cacheUsers = users
                    }
                    
                    if self.cacheUsers.count > 0 {
                        completionBlock(self.cacheUsers.remove(at: 0), nil)
                    } else {
                        completionBlock(nil, "Not found")
                    }
                })
            } else {
                completionBlock(nil, "Not found")
            }
        }
    }
    
    func releaseHandle(){
        if databaseHandle != nil{
            databaseReference.child("users").removeObserver(withHandle: databaseHandle!)
            databaseHandle = nil
        }
    }

    deinit {
       releaseHandle()
    }
    
    
    
    func loadUserDetails(_ completionBlock : @escaping (_ user : TMUser?,_ error : String?) -> Void){
        
        databaseReference.child("users").child(currentUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = TMUser(snapshot: snapshot) else {
                completionBlock(nil, "Details not found.")
                return
            }
            completionBlock(user, nil)
        })
    }
    
    func checkFirstUse(_ completionBlock : @escaping (_ firstUse : Bool?,_ error : String?) -> Void){
        
        databaseReference.child("users").child(currentUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard TMUser(snapshot: snapshot) != nil else {
                completionBlock(true, nil)
                return
            }
            
            completionBlock(false, nil)
        })
    }
    
    func updateUserSettings(_ user : TMUser, completionBlock : @escaping (_ success : Bool, _ error : String?) -> Void){
        let userNode = databaseReference.child("users").child(user.uid)
        
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
