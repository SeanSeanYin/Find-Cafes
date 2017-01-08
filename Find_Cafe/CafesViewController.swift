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
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var musicLabel:UILabel!
    @IBOutlet weak var quietLabel:UILabel!
    @IBOutlet weak var tastyLabel:UILabel!
    @IBOutlet weak var seatLabel:UILabel!
}

class CafeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var wifiLabel:UILabel!
    @IBOutlet var musicLabel:UILabel!
    @IBOutlet var quietLabel:UILabel!
    @IBOutlet var tastyLabel:UILabel!
    @IBOutlet var seatLabel:UILabel!
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
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var line1Label: UILabel!

    
    var searchController:UISearchController!
    // 使用者選擇的城市
    var newCity = ""
    // 使用者目前城市
    var currentCity = ""
    // 排序項目
    var sortItem = "wifi"
    
    var url = ""
    var isHideMap = true
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
        
        cityCafe = getCityString (self.newCity)
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
        
        print("cityCafe:\(cityCafe)")
        
        self.cityButton.setTitle(self.cityCafe, for: .normal)
        
        self.sortButton.frame = CGRect(x: (UIScreen.main.bounds.width) * 0.85, y: self.cityButton.bounds.maxY, width: 40.0, height: 40.0)
        
        getCityData(targetCity: self.newCity)

        //self.cafeDetailTable.register(UINib(nibName: "CafeDetailHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CafeDetailHeader")
        
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

    func getCityString (_ city:String ) -> String {
        
        var str = ""
        print("city:\(city)")
        switch city {
            case "台北", "taipei":
                str = "Taipei Cafe"
            case "新竹", "hsinchu":
                str = "Hsinchu Cafe"
            case "台中", "taichung":
                str = "Taichung Cafe"
            case "台南", "tainan":
                str = "Tainan Cafe"
            case "高雄", "kaohsiung":
                str = "Kaohsiung Cafe"
            default:
                str = "Taipei Cafe"
        }
        
        return str
    }
    
    func getCityData(targetCity:String) {
        
        self.spinner.hidesWhenStopped = true
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
        print("targetCity:\(targetCity)")
        getData(city: targetCity) { response in
            
            if (self.cafes != nil) {
                self.cafes.removeAll()
            }
            
            if (self.sortedCafes != nil) {
                self.sortedCafes.removeAll()
            }
            
            self.cafes = response as! [CafeInfo]
            
            self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
            self.annotations = getAnnotations(from: self.cafes)
            if (self.annotations != nil){
                self.map.addAnnotations(self.annotations)
            }
            OperationQueue.main.addOperation {
                self.spinner.stopAnimating()
                self.cafeDetailTable.reloadData()
                self.cityButton.setTitle(self.getCityString(self.newCity), for: .normal)
            }
        }
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
        self.sortPickerView.doneButton.addTarget(self, action: select, for: UIControlEvents.touchUpInside)
        //替pickerView上面的 一個按鈕  設定一個回應事件
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: select)
        self.maskView.addGestureRecognizer(gesture)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
            case 0:
                self.sortItem = "wifi"
            case 1:
                self.sortItem = "music"
            case 2:
                self.sortItem = "quiet"
            case 3:
                self.sortItem = "tasty"
            case 4:
                self.sortItem = "seat"
            default:
                self.sortItem = "wifi"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 5 }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { return 30.0 }
    
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
        
        if self.cafes != nil { return self.cafes.count } else { return 0 }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 60.0 }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CafeDetailHeader") as! CafeDetailHeader
//        
//        headerView.nameLabel.text = "Cafe's Name"
//        headerView.wifiLabel.text = "Wifi"
//        headerView.musicLabel.text = "Music"
//        headerView.quietLabel.text = "Quiet"
//        headerView.tastyLabel.text = "Tasty"
//        headerView.seatLabel.text = "Seat"
//        headerView.frame = CGRect(x: 0, y: self.line1Label.frame.maxY, width: UIScreen.main.bounds.width, height: 60)
//        
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailCell", for: indexPath) as! CafeDetailTableViewCell

        let currentCafes = self.sortedCafes[indexPath.row]
        
        let wifi = currentCafes.wifi
        let music = currentCafes.music
        let quiet = currentCafes.quiet
        let tasty = currentCafes.tasty
        let seat = currentCafes.seat
        let name = currentCafes.name
    
        cell.wifiLabel.text = String(wifi)
        cell.musicLabel.text = String(music)
        cell.quietLabel.text = String(quiet)
        cell.tastyLabel.text = String(tasty)
        cell.seatLabel.text = String(seat)
        cell.nameLabel.text = name
        
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
                
                let tableViewController = segue.destination as! CityMenuTableViewController
                
                if let popoverController = tableViewController.popoverPresentationController {
                    
                    popoverController.delegate = self
                    popoverController.sourceView = (sender as! UIButton)
                    popoverController.sourceRect = (sender as! UIButton).bounds
                }
            }
        }
    }
    
    func dismiss() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToCafeDetail (_ segue:UIStoryboardSegue) {
        
        let sourceController = segue.source as! CityMenuTableViewController
        self.newCity = sourceController.city

        getCityData(targetCity: self.newCity)
        
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
    
    @IBAction func showSortSheet(_ sender: AnyObject) { showPickerView() }
    
    func hidePickerView(){
        
        UIView.animate(withDuration: 1,
                       animations: {
                        self.maskView.alpha = 0.0
                        self.sortPickerView.frame.origin.y = self.view.frame.height },
                       completion: { success in
                        self.maskView.removeFromSuperview()
                        self.sortPickerView.removeFromSuperview()
                        self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
                        self.cafeDetailTable.reloadData()
        })
    }
}
