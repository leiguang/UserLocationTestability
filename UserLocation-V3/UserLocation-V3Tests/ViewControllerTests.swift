//
//  ViewControllerTests.swift
//  UserLocation-V3Tests
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import XCTest
@testable import UserLocation_V3

class ViewControllerTests: XCTestCase {
    
    var sut: ViewController!
    var locationProvider: UserLocationProviderMock!

    override func setUp() {
        super.setUp()
        
        locationProvider = UserLocationProviderMock()
        sut = ViewController(locationProvider: locationProvider)
    }

    override func tearDown() {
        sut = nil
        locationProvider = nil
        super.tearDown()
    }

    func testRequestUserLocation_NotAuthorized_ShouldFail() {
        // Given
        locationProvider.locationResult = .failure(.canNotBeLocated)
        
        // When
        sut.requestUserLocation()
        
        // Then
        XCTAssertNil(sut.userLocation)
    }
    
    func testRequestUserLocation_Authorized_ShouldReturnUserLocation() {
        // Given
        locationProvider.locationResult = .success(UserLocationMock())
        
        // When
        sut.requestUserLocation()
        
        // Then
        XCTAssertNotNil(sut.userLocation)
    }
}
