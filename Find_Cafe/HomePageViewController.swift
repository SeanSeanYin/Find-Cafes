//
//  HomePageViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import CoreLocation

class HomePageViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var currentCity = ""
    @IBOutlet var cityLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 設置locationManager的參數
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
        } else if CLLocationManager.authorizationStatus() == .denied {
            
            let alert = UIAlertController(title: "無法獲取位置", message: "請允許使用GPS，來獲取您的地理位置。", preferredStyle: .alert)
            let action = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            
            locationManager.requestWhenInUseAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeCity(sender: AnyObject) {
        
        performSegue(withIdentifier: "changeCity", sender: sender)
    }
    
    @IBAction func startToUse(sender: AnyObject) {
        
        switch self.currentCity {
            
            case "台北", "新竹", "台中", "台南", "高雄" :
                
                self.performSegue(withIdentifier: "startToUse", sender: sender)
            
            default:
                
                let alert = UIAlertController(title: "\(self.currentCity) 尚未有資料", message: "將會查詢台北的資料", preferredStyle: .alert)
                
                let doAction = UIAlertAction(title: "確定", style: .default) { action in
                    
                    self.currentCity = "台北"
                    self.performSegue(withIdentifier: "startToUse", sender: sender)
                }
                
                alert.addAction(doAction)
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "changeCity") {

        } else if (segue.identifier == "startToUse") {
            
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! CafesViewController
            
            viewController.selectedCity = self.currentCity
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(locations[locations.count-1]) { (placemark, error) in
            
            if ((error) != nil) {
                    
                return
            } else {
                
                let array = placemark! as NSArray
                let mark = array.firstObject as! CLPlacemark
                print(mark.addressDictionary!)
                self.currentCity = (mark.addressDictionary! as NSDictionary).value(forKey: "State") as! String
                
                self.currentCity = self.currentCity.replacingOccurrences(of: "市", with: "")
                self.currentCity = self.currentCity.replacingOccurrences(of: "縣", with: "")
                self.cityLabel.text = self.currentCity
                self.locationManager.stopUpdatingLocation()
                
                print("currentCity is \(self.currentCity)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        print(error ?? "抓取位置時錯誤！")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
    }
}
