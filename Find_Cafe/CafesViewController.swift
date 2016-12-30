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
    var sortedCafes:[CafeInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedCity:\(selectedCity)")
        
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
        self.spinner.center = self.view.center
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
        
        getData(city: self.selectedCity) { response in
            
            self.cafes = response as! [CafeInfo]
            self.sortedCafes = self.cafes.sorted(by: { $0.wifi! > $1.wifi! })
            //images.sort({ $0.fileID > $1.fileID })
            
            OperationQueue.main.addOperation {
                self.spinner.stopAnimating()
                self.cafeDetailTable.reloadData()
            }
        }        
        
        cafeDetailTable.delegate = self
        cafeDetailTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.cafes != nil {
            return self.cafes.count
        } else {
            return 0
        }
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

        let currentCafes = self.sortedCafes[indexPath.row]
        if let name = currentCafes.name, let wifi = currentCafes.wifi {

            cell.cafeName.text = name
            cell.cafeSort.text = String(wifi)
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
