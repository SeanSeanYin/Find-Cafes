//
//  CafeDetailView.swift
//  Find_Cafe
//
//  Created by V-cube on 2017/1/5.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class CafeDetailView: UIView {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var wifiLabel:UILabel!
    @IBOutlet weak var seatLabel:UILabel!
    @IBOutlet weak var quietLabel:UILabel!
    @IBOutlet weak var tastyLabel:UILabel!
    @IBOutlet weak var musicLabel:UILabel!
    
    var cafe:CafeInfo!
    
    func configureWithCafe(cafe: CafeInfo) {
        self.cafe = cafe
        
        nameLabel.text = cafe.name
        nameLabel.sizeToFit()
        addressLabel.text = cafe.address
        addressLabel.sizeToFit()
        wifiLabel.text = String(cafe.wifi)
        seatLabel.text = String(cafe.seat)
        quietLabel.text = String(cafe.quiet)
        tastyLabel.text = String(cafe.tasty)
        musicLabel.text = String(cafe.music)
    }
}
