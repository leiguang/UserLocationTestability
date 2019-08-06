//
//  LocationProvider.swift
//  UserLocation-V3
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import CoreLocation

protocol LocationProvider {
    var isUserAuthorized: Bool { get }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
}

extension CLLocationManager: LocationProvider {
    var isUserAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
}

