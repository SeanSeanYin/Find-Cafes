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

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

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
            sortedArray = array.sorted(by: { $0.wifi > $1.wifi })
        case "music":
            sortedArray = array.sorted(by: { $0.music > $1.music })
        case "seat":
            sortedArray = array.sorted(by: { $0.seat > $1.seat })
        case "tasty":
            sortedArray = array.sorted(by: { $0.tasty > $1.tasty })
        case "quiet":
            sortedArray = array.sorted(by: { $0.quiet > $1.quiet })
        default :
            break
    }
    
    return sortedArray
}

func getAnnotations (from array:[CafeInfo]) -> [CafeAnnotation] {

    var annotations = [CafeAnnotation]()
    
    for cafe in array {
        
        let annotation = CafeAnnotation(cafe: cafe)
        annotations.append(annotation)
    }
    
    return annotations
}

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var cafeDetailTable:UITableView!
    @IBOutlet weak var spinner:UIActivityIndicatorView!
    @IBOutlet weak var map:MKMapView!
    @IBOutlet weak var cityButton:UIButton!
    
    var searchController:UISearchController!
    var newCity = ""
    var currentCity = ""
    var url = ""
    var sortItem = ""
    var isHideMap = false
    var cafes:[CafeInfo]!
    var sortedCafes:[CafeInfo]!
    var annotations:[CafeAnnotation]!
    var cityCafe = ""
    let locationManager = CLLocationManager()
    var maskView: UIView!
    var sortPickerView:SortPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        initSortPickerView()
        
        switch newCity {
            case "台北":
                newCity = "taipei"
                cityCafe = "Taipei Cafe"
            case "新竹":
                newCity = "hsinchu"
                cityCafe = "Hsinchu Cafe"
            case "台中":
                newCity = "taichung"
            cityCafe = "Taichung Cafe"
            case "台南":
                newCity = "tainan"
            cityCafe = "Tainan Cafe"
            case "高雄":
                newCity = "kaohsiung"
            cityCafe = "Kaohsiung Cafe"
            default:
                newCity = "taipei"
            cityCafe = "Taipei Cafe"
        }
        
        cityButton.setTitle(cityCafe, for: .normal)
        
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

    func initSortPickerView(){
        
        let views: NSArray = UINib(nibName: "SortPickerView", bundle: nil).instantiate(withOwner: self, options: nil) as NSArray
        self.sortPickerView = views.object(at: 0) as! SortPickerView
        self.sortPickerView.pickerView.delegate = self
        self.sortPickerView.pickerView.dataSource = self
        self.maskView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.maskView.backgroundColor = UIColor.black
        self.maskView.alpha = 0.0
        let select : Selector = #selector(CafesViewController.hidePickerView)
        //設定一個action事件
        //self.sortPickerView.okButton.addTarget(self, action: select, for: UIControlEvents.touchUpInside)
        //替pickerView上面的 一個按鈕  設定一個回應事件
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: select)
        self.maskView.addGestureRecognizer(gesture)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row:\(row)")
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 5 }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var str:String = String()
        switch row {
            case 0:
                str = "Wifi"
            case 1:
                str = "Music"
            case 2:
                str = "Quiet"
            case 3:
                str = "Tasty"
            case 4:
                str = "Seat"
            default:
                str = "Wifi"
        }
        return str
    }
    
    func showPickerView() {
        
        self.view.addSubview(self.maskView)
        self.view.addSubview(self.sortPickerView)
        //加入view請注意順序 最後加的  在最上層

        self.maskView.alpha = 0.0
        //設定黑屏的初始透明度
        self.sortPickerView.frame.origin.y = self.view.frame.height
        //設定pickerView的初始位置
        self.sortPickerView.bounds  = CGRect(x: 0, y: self.sortPickerView.bounds.origin.y, width: UIScreen.main.bounds.width, height: self.sortPickerView.bounds.height)
        self.sortPickerView.frame.origin.x = 0
        //設定pickerView與螢幕等寬
        UIView.animate(withDuration: 0.3, animations: {//view移動動畫
            self.maskView.alpha = 0.3
            print(self.sortPickerView.frame)
            self.sortPickerView.frame.origin.y = self.view.frame.height-self.sortPickerView.frame.height
            print(self.sortPickerView.frame)
        })

        if let topController = UIApplication.topViewController() {
            
            print("topController:\(topController.view)")
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
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
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
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView")
        
        if (annotationView == nil) {
            annotationView = CafeAnnotationView(annotation: annotation, reuseIdentifier: "pinView")

        } else { annotationView!.annotation = annotation }
        
        return annotationView
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
                let str = currentCafes.wifi
                cell.cafeSort.text = String(str)
            case "music":
                let str = currentCafes.music
                cell.cafeSort.text = String(str)
            case "quiet":
                let str = currentCafes.quiet
                cell.cafeSort.text = String(str)
            case "tasty":
                let str = currentCafes.tasty
                cell.cafeSort.text = String(str)
            case "seat":
                let str = currentCafes.seat
                cell.cafeSort.text = String(str)
            default :
                break
        }
        
        let name = currentCafes.name
        cell.cafeName.text = name
        print("name : \(name)")
        
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
                    popoverController.sourceView = (sender as! UIButton)
                    popoverController.sourceRect = (sender as! UIButton).bounds
                }
            }
        }
    }
    
    func dismiss() {
        
     //   self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func showMap() {
    
        if (self.isHideMap){
            self.isHideMap = false
            self.view.bringSubview(toFront: map)
        }
    }
    
    @IBAction func showList() {
        
        if (!self.isHideMap){
            self.isHideMap = true
            UIView.animate(withDuration: 0.1, animations: {
                self.map.alpha = 0.0
                self.cafeDetailTable.alpha = 1.0
            }, completion: { success in
                self.cafeDetailTable.reloadData() })

        }
    }
    
    @IBAction func showSortSheet(_ sender: AnyObject) {

        showPickerView()
    }
    
    func hidePickerView(){
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.maskView.alpha = 0.0
                        self.sortPickerView.frame.origin.y = self.view.frame.height },
                       completion: { (value:Bool) in
                        self.maskView.removeFromSuperview()
                        self.sortPickerView.removeFromSuperview()
        })
    }
}
