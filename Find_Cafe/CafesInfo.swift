//
//  CafesInfo.swift
//  Find_Cafe
//
//  Created by V-cube on 2016/12/30.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import Foundation
import CoreLocation

struct CafeInfo {
    
    var id: String?
    var name: String?
    var url: String?
    var city: String?
    var address: String?
    var wifi: Double?
    var seat: Double?
    var quiet: Double?
    var music: Double?
    var tasty: Double?
    var longitude: Double?
    var latitude: Double?
    var location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
}
