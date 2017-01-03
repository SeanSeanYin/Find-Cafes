//
//  CafesViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit
import CoreLocation

class CafeDetailHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
}

class CafeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var cafeName:UILabel!
    @IBOutlet var cafeSort:UILabel!
}

func sort ( with array:[CafeInfo], and sortBy:String) -> [CafeInfo] {
    
    var sortedArray = [CafeInfo]()
    
    switch sortBy{
    
        case "wifi":
            sortedArray = array.sorted(by: { $0.wifi! > $1.wifi! })
        case "music":
            sortedArray = array.sorted(by: { $0.music! > $1.music! })
        case "seat":
            sortedArray = array.sorted(by: { $0.seat! > $1.seat! })
        case "tasty":
            sortedArray = array.sorted(by: { $0.tasty! > $1.tasty! })
        case "quiet":
            sortedArray = array.sorted(by: { $0.quiet! > $1.quiet! })
        default :
            break
    }
    
    return sortedArray
}

func getAnnotations (from array:[CafeInfo]) -> [MKAnnotation] {

    var annotations = [MKAnnotation]()
    
    for cafe in array {
    
        //print("cafe:\(cafe.name), \(cafe.longitude), \(cafe.latitude)")
        if let long = cafe.longitude, let lati = cafe.latitude, let name = cafe.name {
        
            let annotation = MKPointAnnotation()
            annotation.title = name
            annotation.coordinate = CLLocationCoordinate2D(latitude: lati, longitude: long)
            annotations.append(annotation)
            //print("annotation:\(cafe.name), \(cafe.longitude), \(cafe.latitude)")
        }
    }
    
    return annotations
}

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var cafeDetailTable:UITableView!
    @IBOutlet weak var spinner:UIActivityIndicatorView!
    @IBOutlet weak var map:MKMapView!
    
    var searchController:UISearchController!
    var newCity = ""
    var currentCity = ""
    var url = ""
    var sortItem = ""
    var isHideMap = false
    var cafes:[CafeInfo]!
    var sortedCafes:[CafeInfo]!
    var annotations:[MKAnnotation]!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        
        switch newCity {
            case "台北":
                newCity = "taipei"
            case "新竹":
                newCity = "hsinchu"
            case "台中":
                newCity = "taichung"
            case "台南":
                newCity = "tainan"
            case "高雄":
                newCity = "kaohsiung"
            default:
                newCity = "taipei"
        }
        
        self.navigationItem.leftBarButtonItem?.title = newCity
        
        self.spinner.hidesWhenStopped = true
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
        
        print("newCity:\(newCity) & currentCity:\(currentCity)")
        
        if self.sortItem == ""{
            self.sortItem = "wifi"
        }
        
        if (currentCity != newCity) {
            
            getData(city: self.newCity) { response in
                
                self.cafes = response as! [CafeInfo]
                
                self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
                self.annotations = getAnnotations(from: self.cafes)
                if (self.annotations != nil){
                    print(self.annotations)
                    self.map.addAnnotations(self.annotations)
                }
                OperationQueue.main.addOperation {
                    self.spinner.stopAnimating()
                    self.cafeDetailTable.reloadData()
                }
            }
        } else {
            
            if (self.cafes != nil) {
                self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
                self.annotations = getAnnotations(from: self.cafes)
                if (self.annotations != nil){
                    print(self.annotations)
                    self.map.addAnnotations(self.annotations)
                }
                OperationQueue.main.addOperation {
                    self.spinner.stopAnimating()
                    self.cafeDetailTable.reloadData()
                }
            }
        }
        
        self.cafeDetailTable.register(UINib(nibName: "CafeDetailHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CafeDetailHeader")
        
        if (isHideMap) {
            
            self.map.isHidden = true
            self.cafeDetailTable.isHidden = false
            
        } else {
            
            self.map.isHidden = false
            self.cafeDetailTable.isHidden = true
        }
        
        cafeDetailTable.delegate = self
        cafeDetailTable.dataSource = self
        
        map.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initLocationManager() {
        // 設置locationManager的參數
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestLocation()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        
            self.locationManager.startUpdatingLocation()
        
        } else if CLLocationManager.authorizationStatus() == .denied {
        
        let alert = UIAlertController(title: "無法獲取位置", message: "請允許使用GPS，來獲取您的地理位置。", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
        
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[locations.count - 1] as CLLocation
        
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        map.addAnnotation(myAnnotation)
        
        if (self.annotations != nil){
            map.addAnnotations(self.annotations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        print(error ?? "抓取位置時錯誤！")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
    }
    
    private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKPinAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
        
        if (annotationView == nil)
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            annotationView?.pinTintColor = UIColor.blue
            annotationView?.animatesDrop = true
            annotationView?.canShowCallout = true
        } else {
        
            annotationView?.annotation = annotation
        }
        
        return annotationView
        
//        let identifier = "pin"
//        var view: MKPinAnnotationView
//
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//            
//        } else {
//
//            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
//        }
//        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.cafes != nil {
            print("return \(self.cafes.count)")
            return self.cafes.count
        } else {
            print("return 0")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CafeDetailHeader") as! CafeDetailHeader
        
        headerView.nameLabel.text = "Cafe's Name"
        headerView.sortLabel.text = sortItem
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailCell", for: indexPath) as! CafeDetailTableViewCell

        let currentCafes = self.sortedCafes[indexPath.row]
        
        switch sortItem {
            case "wifi":
                if let str = currentCafes.wifi {
                    cell.cafeSort.text = String(str)
                }
            case "music":
                if let str = currentCafes.music {
                    cell.cafeSort.text = String(str)
                }
            case "quiet":
                if let str = currentCafes.quiet {
                    cell.cafeSort.text = String(str)
                }
            case "tasty":
                if let str = currentCafes.tasty {
                    cell.cafeSort.text = String(str)
                }
            case "seat":
                if let str = currentCafes.seat {
                    cell.cafeSort.text = String(str)
                }
            default :
                break
        }
        
        if let name = currentCafes.name {

            cell.cafeName.text = name
            print("name : \(name)")
        }
        
        return cell
    }
    
    @IBAction func showSortMenu(sender: AnyObject ) {
    
        performSegue(withIdentifier: "showSortMenu", sender: sender )
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let id = segue.identifier {
        
            if id == "showSortMenu" {
                
                let tableViewController = segue.destination as! SortTableViewController
                
                if let popoverController = tableViewController.popoverPresentationController {
                    
                    popoverController.delegate = self
                }
            }
        }
    }
    
    func dismiss() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToCafeDetail (_ segue:UIStoryboardSegue) {
        
        let sourceController = segue.source as! SortTableViewController
        self.sortItem = sourceController.sortItem
        print("self.sortItem: \(self.sortItem)")
        
        if (self.cafes != nil){
            self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
        }
        self.cafeDetailTable.reloadData()
    }

    @IBAction func goToSelectCity (_ button:UIBarButtonItem){
    
        self.performSegue(withIdentifier: "backToSelectCity", sender: self)
    }
    
    @IBAction func showMap() {
    
        if (self.isHideMap){
            self.isHideMap = false
            self.view.bringSubview(toFront: map)
        }
    }
    
    @IBAction func showList() {
        
        if (!self.isHideMap){
            self.isHideMap = true
            self.view.bringSubview(toFront:cafeDetailTable)
            //self.cafeDetailTable.reloadData()
        }
    }
}
