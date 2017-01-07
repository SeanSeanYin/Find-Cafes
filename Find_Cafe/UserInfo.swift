//
//  UserInfo.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/7.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import Foundation
import MapKit

class User: NSObject {
    
    enum City {
        case name(String, String, String)
    }
    
    var currentCity: String
    var selectedCity: String
    var coordinate: CLLocationCoordinate2D
    
    static let shared: User = User()
    
    override init () {
        
        self.currentCity = ""
        self.selectedCity = ""
        self.coordinate = kCLLocationCoordinate2DInvalid
        super.init()
    }
}
