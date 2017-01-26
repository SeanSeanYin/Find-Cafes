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
    @IBOutlet weak var routeButton:UIButton!
    @IBOutlet weak var wifiStar1:UIImageView!
    @IBOutlet weak var wifiStar2:UIImageView!
    @IBOutlet weak var wifiStar3:UIImageView!
    @IBOutlet weak var wifiStar4:UIImageView!
    @IBOutlet weak var wifiStar5:UIImageView!
    @IBOutlet weak var seatStar1:UIImageView!
    @IBOutlet weak var seatStar2:UIImageView!
    @IBOutlet weak var seatStar3:UIImageView!
    @IBOutlet weak var seatStar4:UIImageView!
    @IBOutlet weak var seatStar5:UIImageView!
    @IBOutlet weak var tastyStar1:UIImageView!
    @IBOutlet weak var tastyStar2:UIImageView!
    @IBOutlet weak var tastyStar3:UIImageView!
    @IBOutlet weak var tastyStar4:UIImageView!
    @IBOutlet weak var tastyStar5:UIImageView!
    @IBOutlet weak var quietStar1:UIImageView!
    @IBOutlet weak var quietStar2:UIImageView!
    @IBOutlet weak var quietStar3:UIImageView!
    @IBOutlet weak var quietStar4:UIImageView!
    @IBOutlet weak var quietStar5:UIImageView!
    @IBOutlet weak var cheapStar1:UIImageView!
    @IBOutlet weak var cheapStar2:UIImageView!
    @IBOutlet weak var cheapStar3:UIImageView!
    @IBOutlet weak var cheapStar4:UIImageView!
    @IBOutlet weak var cheapStar5:UIImageView!
    @IBOutlet weak var musicStar1:UIImageView!
    @IBOutlet weak var musicStar2:UIImageView!
    @IBOutlet weak var musicStar3:UIImageView!
    @IBOutlet weak var musicStar4:UIImageView!
    @IBOutlet weak var musicStar5:UIImageView!
    
    var cafe:CafeInfo!
    weak var delegate: CafeDetailViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

//        self.applyArrowDialogAppearanceWithOrientation(arrowOrientation: .down)
    }
    
    @IBAction func seeDetails(_ sender: Any) { delegate?.detailsRequestedForCafe(cafe: cafe) }
    
    func countWifiStars(score: Double, starImage:[UIImageView?]) {
        
        let hasRemainder = (score.truncatingRemainder(dividingBy: 1.0) == 0) ? false : true
        for index in 1...5 {
            print(index)
            if ((index-1) < Int(score)) {
                starImage[index-1]?.image = UIImage(named: "ic_star") }
            else {
                starImage[index-1]?.image = (hasRemainder == true) ? UIImage(named: "ic_star_half") : UIImage(named: "ic_star_line")
                
            }
        }
    }
    
    func configureWithCafe(cafe: CafeInfo) {
        
        self.cafe = cafe
        
        nameLabel.text = cafe.name
        nameLabel.sizeToFit()
        addressLabel.text = cafe.address
        addressLabel.sizeToFit()
        let wifiStars = [self.wifiStar1, self.wifiStar2, self.wifiStar3, self.wifiStar4, self.wifiStar5]
        let seatStars = [self.seatStar1, self.seatStar2, self.seatStar3, self.seatStar4, self.seatStar5]
        let quietStars = [self.quietStar1, self.quietStar2, self.quietStar3, self.quietStar4, self.quietStar5]
        let tastyStars = [self.tastyStar1, self.tastyStar2, self.tastyStar3, self.tastyStar4, self.tastyStar5]
        let musicStars = [self.musicStar1, self.musicStar2, self.musicStar3, self.musicStar4, self.musicStar5]
        let cheapStars = [self.cheapStar1, self.cheapStar2, self.cheapStar3, self.cheapStar4, self.cheapStar5]
        countWifiStars(score: cafe.wifi, starImage: wifiStars)
        countWifiStars(score: cafe.seat, starImage: seatStars)
        countWifiStars(score: cafe.tasty, starImage: tastyStars)
        countWifiStars(score: cafe.quiet, starImage: quietStars)
        countWifiStars(score: cafe.cheap, starImage: cheapStars)
        countWifiStars(score: cafe.music, starImage: musicStars)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        return routeButton.hitTest(convert(point, to: routeButton), with: event)
    }
}
