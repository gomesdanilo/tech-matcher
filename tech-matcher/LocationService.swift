//
//  LocationService.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import CoreLocation

class LocationService : NSObject {
    
    var locationManager : CLLocationManager?
    var lastLocation : CLLocation?
    
    class func sharedInstance() -> LocationService {
        struct Singleton {
            static var sharedInstance = LocationService()
        }
        return Singleton.sharedInstance
    }
    
    func startUpdates(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        //locationManager?.distanceFilter = 500 // 500 meters
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdates(){
        locationManager?.stopUpdatingLocation()
    }
    
    func postNotification(){
        let name = Notification.Name(rawValue: "location")
        NotificationCenter.default.post(name: name, object: lastLocation)
    }
}

extension LocationService : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            lastLocation = locations[0]
            postNotification()
        }
    }
}
