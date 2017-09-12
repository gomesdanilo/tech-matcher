//
//  FinderDatasource.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 12/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FinderDatasource {
    
    typealias UserFoundBlock = (_ user : TMUser?, _ error : String?) -> Void
    
    fileprivate var currentUserId : String
    fileprivate var databaseReference: DatabaseReference!
    fileprivate var startingValue : String?
    fileprivate var databaseHandle : DatabaseHandle?
    fileprivate var dataHandled = false
    
    init(currentUserId : String) {
        databaseReference = Database.database().reference()
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
    
    
    func nextUser(completionBlock : @escaping UserFoundBlock){
        
        self.dataHandled = false
        releaseHandle()
        
        databaseHandle = databaseReference.child("users")
            .queryOrderedByKey()
            .observe(.childAdded, with:{ (snapshot1) in
                
                self.startingValue = snapshot1.key
                
                self.databaseReference.child("/userLikes/\(self.currentUserId)/\(snapshot1.key)")
                    .observeSingleEvent(of: .value, with: { (snapshot2) in
                        
                        if self.dataHandled {
                            return
                        }
                        
                        if(!snapshot2.exists()){
                            self.dataHandled = true
                            self.releaseHandle()
                            
                            // Presents user.
                            if let user = TMUser(snapshot: snapshot1) {
                                completionBlock(user, nil)
                            } else {
                                completionBlock(nil, "Failed to parse user")
                            }
                            
                        } else {
                            // Skips this one.
                        }
                    })
                
            })
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
                completionBlock(false, nil)
                return
            }
            
            completionBlock(true, nil)
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
    
}
