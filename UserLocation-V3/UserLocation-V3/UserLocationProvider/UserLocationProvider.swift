//
//  UserLocationProvider.swift
//  UserLocation-V3
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import Foundation
import CoreLocation

typealias UserLocationCompletionBlock = (Result<UserLocation, UserLocationError>) -> Void

protocol UserLocationProvider {
    func findUserLocation(then: @escaping UserLocationCompletionBlock)
}

class UserLocationService: NSObject, UserLocationProvider {
    
    private var provider: LocationProvider
    private var locationCompletionBlock: UserLocationCompletionBlock?
    
    init(provider: LocationProvider) {
        self.provider = provider
        super.init()
    }
    
    func findUserLocation(then: @escaping UserLocationCompletionBlock) {
        self.locationCompletionBlock = then
        if provider.isUserAuthorized {
            provider.startUpdatingLocation()
        } else {
            provider.requestWhenInUseAuthorization()
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            provider.startUpdatingLocation()
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
