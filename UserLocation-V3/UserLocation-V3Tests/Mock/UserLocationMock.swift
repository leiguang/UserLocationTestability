//
//  UserLocationMock.swift
//  UserLocation-V3Tests
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

@testable import UserLocation_V3

struct UserLocationMock: UserLocation {
    var coordinate: Coordinate {
        return Coordinate(latitude: 51.509865, longitude: -0.118092)
    }
}
