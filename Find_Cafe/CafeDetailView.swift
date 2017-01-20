//
//  CafeDetailView.swift
//  Find_Cafe
//
//  Created by V-cube on 2017/1/5.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

protocol CafeDetailViewDelegate: class {
    func detailsRequestedForCafe(cafe: CafeInfo)
}

class CafeDetailView: UIView {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var wifiLabel:UILabel!
    @IBOutlet weak var seatLabel:UILabel!
    @IBOutlet weak var quietLabel:UILabel!
    @IBOutlet weak var tastyLabel:UILabel!
    @IBOutlet weak var musicLabel:UILabel!
    @IBOutlet weak var cheapLabel:UILabel!
    @IBOutlet weak var routeButton:UIButton!
    
    var cafe:CafeInfo!
    weak var delegate: CafeDetailViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

//        self.applyArrowDialogAppearanceWithOrientation(arrowOrientation: .down)
    }
    
    @IBAction func seeDetails(_ sender: Any) { delegate?.detailsRequestedForCafe(cafe: cafe) }
    
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
        cheapLabel.text = String(cafe.cheap)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        return routeButton.hitTest(convert(point, to: routeButton), with: event)
    }
}
