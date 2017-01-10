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
import Koloda

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ cafe:CafeInfo)
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

extension CafesViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ cafe: CafeInfo) {
        
        let center = CLLocationCoordinate2D(latitude: cafe.location.latitude, longitude: cafe.location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        switchTo(map: true)
        self.map.setRegion(region, animated: true)
        
        
        if let ann = self.map.selectedAnnotations[0] as? CafeAnnotation {
            print("selected annotation: \(ann.cafe.name)")
            let c = ann.coordinate
            print("coordinate: \(c.latitude), \(c.longitude)")
            //do something else with ann...
            self.map.addAnnotation(ann)
            self.map.selectAnnotation(ann, animated: true)
        }

        //let anno = CafeAnnotation(cafe: cafe)
        //print("anno:\(anno)")
        //self.map.selectAnnotation(anno, animated: true)
        searchController.searchBar.text = ""
    }
}

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var searchBarContainer:UIView!
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
    var locationSearchTable:LocationSearchTable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        initSortPickerView()
        initSearchController()
        
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController.searchResultsUpdater = locationSearchTable
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search cafe name..."
        self.searchBarContainer.addSubview(searchController.searchBar)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
        
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
        
        self.cityButton.setTitle(self.cityCafe, for: .normal)
        self.sortButton.frame = CGRect(x: (UIScreen.main.bounds.width) * 0.85, y: self.cityButton.bounds.maxY, width: 40.0, height: 40.0)
        
        getCityData(targetCity: self.newCity)

//        self.cafeDetailTable.estimatedRowHeight = 80.0
//        self.cafeDetailTable.rowHeight = UITableViewAutomaticDimension
//        self.cafeDetailTable.register(UINib(nibName: "CafeDetailHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CafeDetailHeader")
        
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

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
//================================= MARK: TableView =================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.cafes != nil { return self.cafes.count } else { return 0 }
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cafe = self.sortedCafes[indexPath.row]
        
        let center = CLLocationCoordinate2D(latitude: cafe.location.latitude, longitude: cafe.location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        switchTo(map: true)
        self.map.setRegion(region, animated: true)
        let anno = CafeAnnotation(cafe: cafe)
        print("anno:\(anno.cafe.name)")
        self.map.selectAnnotation(anno, animated: true)
        searchController.searchBar.text = ""
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
//================================= MARK: PickerView =================================
    
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
    
    func showPickerView() {
        
        self.view.addSubview(self.maskView)
        self.view.addSubview(self.sortPickerView)
        //加入view請注意順序 最後加的  在最上層

        self.maskView.alpha = 0.0
        //設定黑屏的初始透明度
        self.sortPickerView.frame.origin.y = self.view.frame.height
        //設定pickerView的初始位置
        self.sortPickerView.bounds  = CGRect(x: 0, y: self.sortPickerView.bounds.origin.y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.3)//self.sortPickerView.bounds.height)
        self.sortPickerView.frame.origin.x = 0
        //設定pickerView與螢幕等寬
        UIView.animate(withDuration: 0.3, animations: {//view移動動畫
            self.maskView.alpha = 0.3
            print(self.sortPickerView.frame)
            self.sortPickerView.frame.origin.y = self.view.frame.height-self.sortPickerView.frame.height
            print(self.sortPickerView.frame)
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var str = ""
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor(red: 245 / 255, green: 124 / 255, blue: 117 / 255, alpha: 1.0)
        pickerLabel.font = UIFont(name: "Futura Medium", size: 30)
        pickerLabel.textAlignment = NSTextAlignment.center
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
        pickerLabel.text = str
        
        return pickerLabel
    }
    
    func hidePickerView(){
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.maskView.alpha = 0.0
                        self.sortPickerView.frame.origin.y = self.view.frame.height },
                       completion: { success in
                        self.maskView.removeFromSuperview()
                        self.sortPickerView.removeFromSuperview()
                        self.sortedCafes = self.sort(with: self.cafes, and: self.sortItem)
                        self.cafeDetailTable.reloadData()
        })
    }
//================================= MARK: MapView =================================
    
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
        
//        if (self.annotations != nil){
//            map.addAnnotations(self.annotations)
//        }
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        map.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        //let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        //myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        //myAnnotation.title = "Current location"
        //map.addAnnotation(myAnnotation)
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
//================================= MARK: Search Controller =================================
    
    func initSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
    }
    
//================================= MARK: Popover & Segue =================================
    
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }
    
//================================= MARK: @IBAction =================================
    
    @IBAction func showSortMenu(sender: AnyObject ) {
    
        performSegue(withIdentifier: "showSortMenu", sender: sender )
    }
    
    @IBAction func backToCafeDetail (_ segue:UIStoryboardSegue) {
        
        let sourceController = segue.source as! CityMenuTableViewController
        self.newCity = sourceController.city

        getCityData(targetCity: self.newCity)
        
        self.cafeDetailTable.reloadData()
    }
    
    @IBAction func showMap() {
        
        switchTo(map: true)
    }
    
    @IBAction func showList() {
        
        switchTo(map: false)
    }
    
    @IBAction func showSortSheet(_ sender: AnyObject) { showPickerView() }
    
//================================= MARK: Function =================================
    
    func getCityString (_ city:String ) -> String {
        
        var str = ""

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

        getData(city: targetCity) { response in
            
            if (self.cafes != nil) {
                self.cafes.removeAll()
            }
            
            if (self.sortedCafes != nil) {
                self.sortedCafes.removeAll()
            }
            
            self.cafes = response as! [CafeInfo]
            self.locationSearchTable.cafes = self.cafes
            
            self.sortedCafes = self.sort(with: self.cafes, and: self.sortItem)
            self.annotations = self.getAnnotations(from: self.cafes)
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
                sortedArray = array.sorted(by: { $0.wifi > $1.wifi })
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
    
    func switchTo(map:Bool){
        
        if (map && self.isHideMap) {
            
            self.isHideMap = false
            self.map.isHidden = false
            self.cafeDetailTable.isHidden = true
        } else if (!map && !self.isHideMap) {
            
            self.isHideMap = true
            self.cafeDetailTable.isHidden = false
            self.map.isHidden = true
        }
    }
    
    func dismiss() {
        
        self.dismiss(animated: true, completion: nil)
    }
}
