//
//  ConnectivityHandler.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 15/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ConnectivityHandler: NSObject {
    
    fileprivate var _connected = true
    fileprivate var _databaseHandle : DatabaseHandle!
    
    var connected : Bool {
        get {
            return _connected
        }
    }
    
    class func sharedInstance() -> ConnectivityHandler {
        struct Singleton {
            static var sharedInstance = ConnectivityHandler()
        }
        return Singleton.sharedInstance
    }

    override init() {
        super.init()
        
        handleOfflineConnection()
    }
    
    
    func handleOfflineConnection() {
        
        
        _databaseHandle = Database.database().reference(withPath: ".info/connected").observe(.value, with: { (snapshot) in
            
            if let value = snapshot.value as? Bool {
                if value {
                    self.onConnect()
                } else {
                    self.onDisconnect()
                }
            } else {
                self.onDisconnect()
            }
            
        }) { (error) in
            self.onDisconnect()
        }
        
    }
    
    func onDisconnect() {
        _connected = false
        print("Device lost connectivity")
    }
    
    func onConnect(){
        _connected = true
        print("Device got connected")
    }
    
    deinit {
        Database.database().reference(withPath: ".info/connected").removeObserver(withHandle: self._databaseHandle!)
    }
}
