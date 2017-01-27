//
//  CafeAnnotationView.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/3.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import MapKit

class CafeAnnotationView: MKAnnotationView {
    weak var cafeDetailViewDelegate: CafeDetailViewDelegate?
    weak var customCalloutView: CafeDetailView?
    override var annotation: MKAnnotation? {
        willSet {customCalloutView?.removeFromSuperview() }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = UIImage(named: "btn_flag_n")
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = UIImage(named: "btn_flag_n")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
        
            self.customCalloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = loadCafeDetailView() {

                newCustomCalloutView.frame.origin.x -= (newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0))
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.customCalloutView!.alpha = 1.0
                        self.image = UIImage(named: "btn_flag_selected")
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated {
                    UIView.animate(withDuration: 0.3,
                                   animations: {self.customCalloutView!.alpha = 0.0},
                                   completion: { success in self.customCalloutView!.removeFromSuperview() })
                } else { self.customCalloutView!.removeFromSuperview() }
            }
            self.image = UIImage(named: "btn_flag_n")
        }
    }
    
    func loadCafeDetailView() -> CafeDetailView? {
        if let views = Bundle.main.loadNibNamed("CafeDetailView", owner: self, options: nil) as? [CafeDetailView], views.count > 0 {
            let cafeDetailView = views.first!
            cafeDetailView.delegate  = self.cafeDetailViewDelegate
            if let cafeAnnotation = annotation as? CafeAnnotation {                
                let cafe = cafeAnnotation.cafe
                cafeDetailView.configureWithCafe(cafe: cafe)
            }
            return cafeDetailView
        }
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }
}
