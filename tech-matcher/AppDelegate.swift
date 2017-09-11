//
//  AppDelegate.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 11/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        LocationService.sharedInstance().stopUpdates()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        LocationService.sharedInstance().stopUpdates()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        LocationService.sharedInstance().startUpdates()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        LocationService.sharedInstance().startUpdates()
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

