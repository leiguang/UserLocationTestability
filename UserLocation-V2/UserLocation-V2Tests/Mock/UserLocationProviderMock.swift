//
//  UserLocationProviderMock.swift
//  UserLocation-V2Tests
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

@testable import UserLocation_V2

class UserLocationProviderMock: UserLocationProvider {
    
    var locationResult: Result<UserLocation, UserLocationError>?
    
    func findUserLocation(then: @escaping UserLocationCompletionBlock) {
        if let result = locationResult {
            then(result)
        }
    }
}
