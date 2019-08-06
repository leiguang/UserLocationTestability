//
//  LocationProviderMock.swift
//  UserLocation-V3Tests
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

@testable import UserLocation_V3

class LocationProviderMock: LocationProvider {
    
    var isRequestWhenInUseAuthorizationCalled = false
    var isStartUpdatingLocationCalled = false

    var isUserAuthorized: Bool = false
    
    func requestWhenInUseAuthorization() {
        isRequestWhenInUseAuthorizationCalled = true
    }
    
    func startUpdatingLocation() {
        isStartUpdatingLocationCalled = true
    }
}
