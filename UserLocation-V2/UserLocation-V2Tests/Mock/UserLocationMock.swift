//
//  UserLocationMock.swift
//  UserLocation-V2Tests
//
//  Created by Guang Lei on 2019/8/5.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

@testable import UserLocation_V2

struct UserLocationMock: UserLocation {
    var coordinate: Coordinate {
        return Coordinate(latitude: 51.509865, longitude: -0.118092)
    }
}


