//
//  CafesViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import SwiftyJSON

class CafeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var cafeName:UILabel!
    @IBOutlet var cafeSort:UILabel!
}

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var cafeDetailTable:UITableView!
    @IBOutlet var spinner:UIActivityIndicatorView!
    
    var searchController:UISearchController!
    var selectedCity = ""
    var url = ""
    var cafes:[CafeInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedCity:\(selectedCity)")
        
        cafeDetailTable.delegate = self
        cafeDetailTable.dataSource = self
        
        switch selectedCity {
        case "台北":
            selectedCity = "taipei"
        case "新竹":
            selectedCity = "hsinchu"
        case "台中":
            selectedCity = "taichung"
        case "台南":
            selectedCity = "tainan"
        case "高雄":
            selectedCity = "kaohsiung"
        default:
            selectedCity = "taipei"
        }
        
        self.spinner.hidesWhenStopped = true
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        do {
            _ = try getData(city: selectedCity) { response in
                
                switch (response.result){
                    case .success(let value) :
                        
                        let objArray = JSON(value)
                        
                        for (_, obj) in objArray {
                            
                            let id = obj["id"].stringValue
                            let name = obj["name"].stringValue
                            let url = obj["url"].stringValue
                            let city = obj["city"].stringValue
                            let address = obj["address"].stringValue
                            let wifi = obj["wifi"].doubleValue
                            let seat = obj["seat"].doubleValue
                            let quiet = obj["quiet"].doubleValue
                            let music = obj["music"].doubleValue
                            let tasty = obj["tasty"].doubleValue
                            let longitude = obj["longitude"].doubleValue
                            let latitude = obj["latitude"].doubleValue
                            
                            let cafe = CafeInfo(id: id, name: name, url: url, city: city, address: address, wifi: wifi, seat: seat, quiet: quiet, music: music, tasty: tasty, longitude:longitude, latitude: latitude)
                            
                            if self.cafes == nil {
                                self.cafes = [CafeInfo]()
                            }
                            
                            self.cafes.append(cafe)
                        }
                    default:
                        print("Just default")
                }
                OperationQueue.main.addOperation {
                    self.spinner.stopAnimating()
                    self.cafeDetailTable.reloadData()
                }
                print("Cafes:\(self.cafes.count)")
            }
        } catch ApiError.makeSignatureFail {
            
            print("Failed to make signature.")
        } catch {
            
            print("Something worng")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
        //return cafes.count
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//        return 44.0
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
//        
//        headerView.nameLabel.text = "Cafe's Name"
//        headerView.sortLabel.text = sortBy.rawValue
//        
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailCell", for: indexPath) as! CafeDetailTableViewCell


        cell.cafeName.text = "name"
        cell.cafeSort.text = "wifi"
//        let currentCafes = cafes[indexPath.row]
//        if let name = currentCafes.name, let wifi = currentCafes.wifi {
//            print("name: \(name),  sort:\(wifi)")
//            cell.cafeName.text = name
//            cell.cafeSort.text = String(wifi)
//        }
        
        return cell
    }
    
    @IBAction func showSortMenu(sender: AnyObject ) {
    
        performSegue(withIdentifier: "showSortMenu", sender: sender )
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "showSortMenu" {
            
            let tableViewController = segue.destination as! SortTableViewController
            
            if let popoverController = tableViewController.popoverPresentationController {
                
                popoverController.delegate = self
            }
        }
    }
    
    func dismiss() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
