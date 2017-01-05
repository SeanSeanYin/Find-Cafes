//
//  CafesInfo.swift
//  Find_Cafe
//
//  Created by V-cube on 2016/12/30.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import Foundation
import MapKit

class CafeInfo: NSObject {
    
    var id: String
    var name: String
    var url: String
    var city: String
    var address: String
    var wifi: Double
    var seat: Double
    var quiet: Double
    var music: Double
    var tasty: Double
    var location:CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    
    init (id: String, name: String, url: String, city: String, address: String, wifi: Double, seat: Double, quiet: Double, music: Double, tasty: Double, location: CLLocationCoordinate2D){
    
        self.id = id
        self.name = name
        self.url = url
        self.city = city
        self.address = address
        self.wifi = wifi
        self.seat = seat
        self.quiet = quiet
        self.music = music
        self.tasty = tasty
        self.location = location
    }
}
