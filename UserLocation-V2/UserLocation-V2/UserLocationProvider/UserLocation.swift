//
//  UserLocation.swift
//  UserLocation-V2
//
//  Created by Guang Lei on 2019/8/5.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import CoreLocation

typealias Coordinate = CLLocationCoordinate2D

protocol UserLocation {
    var coordinate: Coordinate { get }
}

extension CLLocation: UserLocation {}
