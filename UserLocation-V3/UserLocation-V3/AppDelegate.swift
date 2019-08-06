//
//  AppDelegate.swift
//  UserLocation-V3
//
//  Created by Guang Lei on 2019/8/5.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let locationProvider = CLLocationManager()
        let userLocationService = UserLocationService(provider: locationProvider)
        locationProvider.delegate = userLocationService
        let viewController = ViewController(locationProvider: userLocationService)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

