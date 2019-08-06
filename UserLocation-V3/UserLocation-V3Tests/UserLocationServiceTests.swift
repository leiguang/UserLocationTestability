//
//  UserLocationServiceTests.swift
//  UserLocation-V3Tests
//
//  Created by Guang Lei on 2019/8/6.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import XCTest
@testable import UserLocation_V3

class UserLocationServiceTests: XCTestCase {
    
    var sut: UserLocationService!
    var locationProvider: LocationProviderMock!

    override func setUp() {
        super.setUp()
        locationProvider = LocationProviderMock()
        sut = UserLocationService(provider: locationProvider)
    }

    override func tearDown() {
        sut = nil
        locationProvider = nil
        super.tearDown()
    }
    
    func testRequestUserLocation_NotAuthorized_ShouldRequestAuthorization() {
        // Given
        locationProvider.isUserAuthorized = false
        
        // When
        sut.findUserLocation { _ in }
        
        // Then
        XCTAssertTrue(locationProvider.isRequestWhenInUseAuthorizationCalled)
    }
    
    func testRequestUserLocation_Authorized_ShouldNotRequestAuthorization() {
        // Given
        locationProvider.isUserAuthorized = true
        
        // When
        sut.findUserLocation { _ in }
        
        // Then
        XCTAssertFalse(locationProvider.isRequestWhenInUseAuthorizationCalled)
    }
    
    func testStartUpdatingUserLocation_NotAuthorized_ShouldNotUpdateUserLocation() {
        // Given
        locationProvider.isUserAuthorized = false
        
        // When
        sut.findUserLocation { _ in }
        
        // Then
        XCTAssertFalse(locationProvider.isStartUpdatingLocationCalled)
    }
    
    func testStartUpdatingUserLocation_Authorized_ShouldUpdateUserLocation() {
        // Given
        locationProvider.isUserAuthorized = true
        
        // When
        sut.findUserLocation { _ in }
        
        // Then
        XCTAssertTrue(locationProvider.isStartUpdatingLocationCalled)
    }
}
