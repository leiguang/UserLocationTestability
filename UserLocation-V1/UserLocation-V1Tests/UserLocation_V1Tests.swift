//
//  UserLocation_V1Tests.swift
//  UserLocation-V1Tests
//
//  Created by Guang Lei on 2019/8/5.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import XCTest
import CoreLocation
@testable import UserLocation_V1

class UserLocation_V1Tests: XCTestCase {
    
    var sut: ViewController!

    override func setUp() {
        super.setUp()
        sut = ViewController(locationProvider: CLLocationManager())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testRequestUserLocation() {
        sut.requestUserLocation()
        XCTAssertNotNil(sut.userLocation)
    }

}
