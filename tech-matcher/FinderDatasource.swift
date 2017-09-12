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
    
    init(currentUserId : String) {
        databaseReference = Database.database().reference()
        self.currentUserId = currentUserId
    }
    
    func firstUser(completionBlock : @escaping UserFoundBlock){
        
        releaseHandle()
        
        
        databaseHandle = databaseReference.child("users")
                        .queryOrderedByKey()
                        .observe(.childAdded, with:{ (snapshot1) in
                
                        self.startingValue = snapshot1.key
                            
                        self.databaseReference.child("/userLikes/\(self.currentUserId)/\(snapshot1.key)")
                            .observeSingleEvent(of: .childAdded, with: { (snapshot2) in
                            
                                if(!snapshot2.exists()){
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
    
    func nextUser(startingValue: String, completionBlock : @escaping UserFoundBlock){
        releaseHandle()
        
        databaseHandle = databaseReference.child("users")
            .queryOrderedByKey()
            .queryStarting(atValue: startingValue)
            .observe(.childAdded, with:{ (snapshot1) in
                
                self.startingValue = snapshot1.key
                
                self.databaseReference.child("/userLikes/\(self.currentUserId)/\(snapshot1.key)")
                    .observeSingleEvent(of: .childAdded, with: { (snapshot2) in
                        
                        if(!snapshot2.exists()){
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
    
    func nextUser(completionBlock : @escaping UserFoundBlock){
        
        if let startingValue = startingValue {
            nextUser(startingValue: startingValue, completionBlock: completionBlock)
        } else {
            firstUser(completionBlock: completionBlock)
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

}
