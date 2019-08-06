//
//  ViewController.swift
//  UserLocation-V3
//
//  Created by Guang Lei on 2019/8/5.
//  Copyright © 2019 Guang Lei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var locationProvider: UserLocationProvider
    var userLocation: UserLocation?
    
    init(locationProvider: UserLocationProvider) {
        self.locationProvider = locationProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestUserLocation() {
        locationProvider.findUserLocation { [weak self] (result) in
            switch result {
            case .success(let location):
                self?.userLocation = location
            case .failure:
                print("User can not be located 😔 ")
            }
        }
    }
}

