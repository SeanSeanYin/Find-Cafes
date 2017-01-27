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

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ cafe:CafeInfo)
}

protocol CityMenuDelegate {
    func showSelectedCity(city:String)
    func getSelectedCity() -> String
}

class CafeDetailHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var musicLabel:UILabel!
    @IBOutlet weak var quietLabel:UILabel!
    @IBOutlet weak var tastyLabel:UILabel!
    @IBOutlet weak var seatLabel:UILabel!
    @IBOutlet weak var cheapLabel:UILabel!
}

class CafeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var wifiLabel:UILabel!
    @IBOutlet var musicLabel:UILabel!
    @IBOutlet var quietLabel:UILabel!
    @IBOutlet var tastyLabel:UILabel!
    @IBOutlet var seatLabel:UILabel!
    @IBOutlet var cheapLabel:UILabel!
}

extension CafesViewController: CityMenuDelegate {
    
    internal func showSelectedCity(city: String) {
        self.newCity = city
        getCityData(targetCity: self.newCity)
        
        if (self.newCity != self.oldCity) {
            self.oldCity = self.newCity
            locateAtStation()
            self.cityButton.setTitle(getCityString(city), for: .normal)
        }
        
        self.cafeDetailTable.reloadData()
    }
    
    internal func getSelectedCity() -> String {
        
        guard (self.oldCity != "") else { return "taipei"}
        return self.oldCity
    }
}

extension CafesViewController : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension CafesViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ cafe: CafeInfo) {
        
        let center = CLLocationCoordinate2D(latitude: cafe.location.latitude, longitude: cafe.location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        switchTo(map: true)
        self.map.setRegion(region, animated: true)
        self.selectedCafe = cafe
        
        let anno = CafeAnnotation(cafe: cafe)
        self.map.addAnnotation(anno)
        map.selectAnnotation(anno, animated: true)
        
        searchController.searchBar.text = ""
    }
}

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CafeDetailViewDelegate {

    @IBOutlet weak var searchBarContainer:UIView!
    @IBOutlet weak var cafeDetailTable:UITableView!
    @IBOutlet weak var spinner:UIActivityIndicatorView!
    @IBOutlet weak var map:MKMapView!
    @IBOutlet weak var cityButton:UIButton!
    @IBOutlet weak var sortButton:UIButton!
    @IBOutlet weak var mapButton:UIButton!
    @IBOutlet weak var line1Label:UILabel!
    @IBOutlet weak var wifiHeaderLabel:UILabel!
    @IBOutlet weak var seatHeaderLabel:UILabel!
    @IBOutlet weak var quietHeaderLabel:UILabel!
    @IBOutlet weak var tastyHeaderLabel:UILabel!
    @IBOutlet weak var cheapHeaderLabel:UILabel!
    @IBOutlet weak var musicHeaderLabel:UILabel!
    
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
    var userLocation:CLLocationCoordinate2D?
    var maskView: UIView!
    var sortPickerView:SortPickerView!
    var locationSearchTable:LocationSearchTable!
    var oldCity = ""
    var hasUserLocation = false
    var isFirstSwitch = true
    var selectedCafe:CafeInfo?
    let interactor = Interactor()
    let taipeiStation = CLLocationCoordinate2D(latitude: 25.047641, longitude: 121.516865)
    let hsinchuStation = CLLocationCoordinate2D(latitude: 24.801550, longitude: 120.971678)
    let taichungStation = CLLocationCoordinate2D(latitude: 24.137476, longitude: 120.686889)
    let tainanStation = CLLocationCoordinate2D(latitude: 22.997106, longitude: 120.212622)
    let kaohsiungStation = CLLocationCoordinate2D(latitude: 22.639761, longitude: 120.302397)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        initSortPickerView()
        initSearchController()
        
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController.searchResultsUpdater = locationSearchTable
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search cafe name or address..."
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
        oldCity = newCity
        self.cityButton.setTitle(self.cityCafe, for: .normal)
        
        getCityData(targetCity: self.newCity)
        
        if (isHideMap) {
            
            self.map.isHidden = true
            self.cafeDetailTable.isHidden = false
        } else {
            
            self.map.isHidden = false
            self.cafeDetailTable.isHidden = true
            self.sortButton.imageView?.image = UIImage(named: "btn_current_location_n")
        }
        
        self.cafeDetailTable.separatorStyle = .none
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
        
        cell.backgroundColor = (indexPath.row % 2 == 1) ? UIColor.white : UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1.0)
        
        let currentCafes = self.sortedCafes[indexPath.row]
        
        let wifi = currentCafes.wifi
        let music = currentCafes.music
        let quiet = currentCafes.quiet
        let tasty = currentCafes.tasty
        let seat = currentCafes.seat
        let cheap = currentCafes.cheap
        let name = currentCafes.name
        
        self.wifiHeaderLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        self.seatHeaderLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        self.quietHeaderLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        self.tastyHeaderLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        self.cheapHeaderLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        self.musicHeaderLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        cell.wifiLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        cell.seatLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        cell.quietLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        cell.tastyLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        cell.cheapLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        cell.musicLabel.textColor = UIColor(red: 12/255, green: 44/255, blue: 81/255, alpha: 1.0)
        
        switch (self.sortItem){
            case "wifi":
                self.wifiHeaderLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
                cell.wifiLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
            case "seat":
                self.seatHeaderLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
                cell.seatLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
            case "quiet":
                self.quietHeaderLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
                cell.quietLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
            case "tasty":
                self.tastyHeaderLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
                cell.tastyLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
            case "cheap":
                self.cheapHeaderLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
                cell.cheapLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
            case "music":
                self.musicHeaderLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
                cell.musicLabel.textColor = UIColor(red: 255/255, green: 77/255, blue: 77/255, alpha: 1.0)
            default:
                break
        }
        
        cell.wifiLabel.text = String(wifi)
        cell.musicLabel.text = String(music)
        cell.quietLabel.text = String(quiet)
        cell.tastyLabel.text = String(tasty)
        cell.seatLabel.text = String(seat)
        cell.cheapLabel.text = String(cheap)
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
        self.map.addAnnotation(anno)
        map.selectAnnotation(anno, animated: true)
        searchController.searchBar.text = ""
    }
    
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
            case 5:
                self.sortItem = "cheap"
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
        self.sortPickerView.frame.origin.y = self.view.frame.height
        //設定pickerView的初始位置
        self.sortPickerView.bounds  = CGRect(x: 0, y: self.sortPickerView.bounds.origin.y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.3)//self.sortPickerView.bounds.height)
        self.sortPickerView.frame.origin.x = 0
        //設定pickerView與螢幕等寬
        UIView.animate(withDuration: 0.3, animations: {//view移動動畫
            self.maskView.alpha = 0.3
            self.sortPickerView.frame.origin.y = self.view.frame.height-self.sortPickerView.frame.height
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
        case 5:
            str = "Cheap"
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
            
            self.hasUserLocation = false
            
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            self.hasUserLocation = false
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[locations.count - 1] as CLLocation
        
        if (self.annotations != nil){
            map.addAnnotations(self.annotations)
        }
        
        self.userLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        self.hasUserLocation = true
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
            (annotationView as! CafeAnnotationView).cafeDetailViewDelegate = self
        } else { annotationView!.annotation = annotation }
        
        return annotationView
    }
//================================= MARK: Search Controller =================================
    
    func initSearchController() {
        searchController = UISearchController(searchResultsController: nil)}
    
//================================= MARK: Popover & Segue =================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if let id = segue.identifier {
            
            if (id == "showSortMenu") {
                
                let tableViewController = segue.destination as! SortTableViewController
                if let popoverController = tableViewController.popoverPresentationController {
                    
                    popoverController.delegate = self
                    popoverController.sourceView = (sender as! UIButton)
                    popoverController.sourceRect = (sender as! UIButton).bounds
                }
            } else if (id == "showSelectCity") {
                if let destinationViewController = segue.destination as? CityMenuViewController {
                    destinationViewController.transitioningDelegate = self
                    destinationViewController.interactor = interactor
                    destinationViewController.cityMenuDelegate = self
                }
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }
//================================= MARK: @IBAction =================================
    
    @IBAction func showSortMenuOrLocateUser(sender: AnyObject ) {
    
        if (self.isHideMap){ performSegue(withIdentifier: "showSortMenu", sender: sender) }
        else { locateUser() }
    }
    
    @IBAction func backToCafeDetail (_ segue:UIStoryboardSegue) {
        
        let sourceController = segue.source as! SortTableViewController
        self.sortItem = sourceController.sort
        self.sortedCafes = self.sort(with: self.cafes, and: self.sortItem)
        self.cafeDetailTable.reloadData()
    }
    
    @IBAction func showMap() {
        
        if (self.isHideMap) { switchTo(map: true) }
        else { switchTo(map: false) }
    }
    
    @IBAction func showCityMenu(_ sender: AnyObject) { performSegue(withIdentifier: "showSelectCity", sender: nil ) }
    
    @IBAction func edgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .right)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "showSelectCity", sender: nil)
        }
    }
//================================= MARK: Function =================================
    
    func getCityString (_ city:String ) -> String {
        
        var str = ""

        switch city {
            case "台北", "taipei":
                str = "Taipei"
            case "新竹", "hsinchu":
                str = "Hsinchu"
            case "台中", "taichung":
                str = "Taichung"
            case "台南", "tainan":
                str = "Tainan"
            case "高雄", "kaohsiung":
                str = "Kaohsiung"
            default:
                str = "Taipei"
        }
        return str
    }
    
    func getCityData(targetCity:String) {
        
        self.spinner.hidesWhenStopped = true
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()

        do {
            try getData(city: targetCity) { response, error in
                
                guard (error == nil) else {
                    OperationQueue.main.addOperation { self.spinner.stopAnimating() }
                    let alert = UIAlertController(title: "獲取資料失敗", message: "請確認網路狀態後，重新選擇城市", preferredStyle: .alert)
                    let doAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                    alert.addAction(doAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if (self.cafes != nil) { self.cafes.removeAll() }
                if (self.sortedCafes != nil) { self.sortedCafes.removeAll() }
                
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
        } catch {
            OperationQueue.main.addOperation { self.spinner.stopAnimating() }
            let alert = UIAlertController(title: "獲取資料失敗", message: "請重新選擇城市來再次獲取資料", preferredStyle: .alert)
            let doAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(doAction)
        }
    }
    
    func sort( with array:[CafeInfo], and sortBy:String) -> [CafeInfo] {
        
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
            case "cheap":
                sortedArray = array.sorted(by: { $0.cheap > $1.cheap })
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

    func locateAtStation() {
        
        var station:CLLocationCoordinate2D!

        switch self.newCity {
            case "taipei":
                station = taipeiStation
            case "hsinchu":
                station = hsinchuStation
            case "taichung":
                station = taichungStation
            case "tainan":
                station = tainanStation
            case "kaohsiung":
                station = kaohsiungStation
            default:
                station = taipeiStation
        }

        let region = MKCoordinateRegion(center: station, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
    }
    
    func switchTo(map:Bool){
        
        if (map && self.isHideMap) {
            
            self.isHideMap = false
            self.map.isHidden = false
            self.cafeDetailTable.isHidden = true
            self.mapButton.setTitle("List", for: .normal)
            self.sortButton.setImage(UIImage(named: "btn_current_location_n"), for: .normal)
            if (!hasUserLocation && self.isFirstSwitch) {
                let alert = UIAlertController(title: "無法獲取使用者位置", message: "預設定位到各城市的火車站", preferredStyle: .alert)
                let doAction = UIAlertAction(title: "確定", style: .default) { action in
                    self.locateAtStation() }
                alert.addAction(doAction)
                self.present(alert, animated: true, completion: nil)
            }
            else if (!hasUserLocation && self.isFirstSwitch) { locateUser() }

        } else if (!map && !self.isHideMap) {
            
            self.isHideMap = true
            self.cafeDetailTable.isHidden = false
            self.map.isHidden = true
            self.mapButton.setTitle("Map", for: .normal)
            self.sortButton.setImage(UIImage(named: "btn_sort_n"), for: .normal)
        }
        
        self.isFirstSwitch = false
    }
    
    func dismiss() { self.dismiss(animated: true, completion: nil) }
    
    func locateUser(){
        
        guard (self.hasUserLocation) else {
            let alert = UIAlertController(title: "定位失敗", message: "請確認「定位服務」有開啟", preferredStyle: .alert)
            let doAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(doAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let region = MKCoordinateRegion(center: (self.userLocation)!, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        map.setRegion(region, animated: true)
    }
    
    internal func detailsRequestedForCafe(cafe: CafeInfo) {
        
        let selectedCafe = MKPlacemark(coordinate: cafe.location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: selectedCafe)
        mapItem.name = cafe.name
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
