//
//  UserLocationProvider.swift
//  UserLocation-V2
//
//  Created by Guang Lei on 2019/8/5.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import Foundation
import CoreLocation

typealias UserLocationCompletionBlock = (Result<UserLocation, UserLocationError>) -> Void

protocol UserLocationProvider {
    func findUserLocation(then: @escaping UserLocationCompletionBlock)
}

class UserLocationService: NSObject, UserLocationProvider {
    
    private let locationManager = CLLocationManager()
    private var locationCompletionBlock: UserLocationCompletionBlock?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func findUserLocation(then: @escaping UserLocationCompletionBlock) {
        self.locationCompletionBlock = then
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationCompletionBlock?(.success(location))
        } else {
            locationCompletionBlock?(.failure(.canNotBeLocated))
        }
    }
}
