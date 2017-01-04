//
//  CafeAnnotationView.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/3.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

protocol CafeAnnotationViewDelegate:class{
    
    func detailsRequestedForCafe(cafe: CafeInfo)
}

extension Double {

    func toString() -> String {
        
        return String(format: "%.1f", self)
    }
}

class CafeAnnotationView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var quietLabel: UILabel!
    @IBOutlet weak var tastyLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!

    var cafe:CafeInfo!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    func showCafeInfo (cafe:CafeInfo!) {
    
        self.cafe = cafe
        
        self.nameLabel.text = self.cafe.name
        self.addressLabel.text = self.cafe.address
        self.wifiLabel.text = (self.cafe.wifi)?.toString()
        self.tastyLabel.text = (self.cafe.tasty)?.toString()
        self.quietLabel.text = self.cafe.quiet?.toString()
        self.musicLabel.text = self.cafe.music?.toString()
        self.seatLabel.text = self.cafe.seat?.toString()
    }
}
