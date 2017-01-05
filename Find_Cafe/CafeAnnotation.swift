//
//  CafeAnnotation.swift
//  Find_Cafe
//
//  Created by V-cube on 2017/1/5.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import MapKit

class CafeAnnotation: NSObject, MKAnnotation {

    var cafe: CafeInfo
    var coordinate: CLLocationCoordinate2D { return cafe.location }
    
    init(cafe: CafeInfo) {
        self.cafe = cafe
        super.init()
    }
    
    var title: String? {
        return cafe.name
    }
    
    var subtitle: String? {
        return cafe.address
    }
}
