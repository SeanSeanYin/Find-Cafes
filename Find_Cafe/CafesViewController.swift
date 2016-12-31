//
//  CafesViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import SwiftyJSON

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

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var cafeDetailTable:UITableView!
    @IBOutlet var spinner:UIActivityIndicatorView!
    
    var searchController:UISearchController!
    var newCity = ""
    var currentCity = ""
    var url = ""
    var sortItem = ""
    var cafes:[CafeInfo]!
    var sortedCafes:[CafeInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                OperationQueue.main.addOperation {
                    self.spinner.stopAnimating()
                    self.cafeDetailTable.reloadData()
                }
            }
        } else {
            
            if (self.cafes != nil) {
                self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
                
                OperationQueue.main.addOperation {
                    self.spinner.stopAnimating()
                    self.cafeDetailTable.reloadData()
                }
            }
        }
        
        self.cafeDetailTable.register(UINib(nibName: "CafeDetailHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CafeDetailHeader")
        
        cafeDetailTable.delegate = self
        cafeDetailTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func unwindToMainPage (_ segue: UIStoryboardSegue) {
        
        let sourceController = segue.source as! SortTableViewController
        self.sortItem = sourceController.sortItem
        if (self.cafes != nil) {
            self.sortedCafes = sort(with: self.cafes, and: self.sortItem)
        }
        
        self.cafeDetailTable.reloadData()
    }
}
