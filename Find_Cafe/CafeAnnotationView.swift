//
//  CafeAnnotationView.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/3.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import MapKit

protocol CafeAnnotationViewDelegate:class{
    
    func detailsRequestedForCafe(cafe: CafeInfo)
}

extension Double {

    func toString() -> String {
        
        return String(format: "%.1f", self)
    }
}

class customCafeAnnotationView: MKAnnotationView {

    // data
    weak var customCalloutView: CafeAnnotationView?
    override var annotation: MKAnnotation? {
    
        willSet{ customCalloutView?.removeFromSuperview() }
    }
    
    // MARK: life cycle
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
    
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = UIImage(named: "coffee_pin")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = UIImage(named: "coffee_pin")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
        if selected {
            
            //remove old custom callout
            self.customCalloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = loadCafeDetailMapView(){
            
                    // fix location from top-left to its right place
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                //set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                if animated {
                
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 1.0, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
        
            if customCalloutView != nil {
                // fade out animation, then remove it
                if animated {
                    UIView.animate(withDuration: 1.0, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { success in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else { self.customCalloutView!.removeFromSuperview() }
            }
        }
    }
    
    func loadCafeDetailMapView() -> UIView? {
    
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 280))
        return view
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
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
