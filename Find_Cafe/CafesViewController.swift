//
//  CafesViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class CafeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var cafeName:UILabel!
    @IBOutlet var cafeSort:UILabel!
}

class CafesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var cafeDetailTable:UITableView!
    
    var searchController:UISearchController!
    var selectedCity = ""
    var url = ""
    var cafes:[CafeInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedCity:\(selectedCity)")
        
        getData(city: selectedCity, completion: <#T##(DataResponse<Any>) -> Void#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cafes.count
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
        let currentCafes = cafes[indexPath.row]
        
        if let name = currentCafes.name {
            cell.cafeName.text = name
        }
        
        switch (sortBy) {
        case .wifi:
            if let wifi = currentCafes.wifi {
                cell.cafeSort.text = String(wifi)
            }
            break
        case .music:
            if let music = currentCafes.music {
                cell.cafeSort.text = String(music)
            }
            break
        case .seat:
            if let seat = currentCafes.seat {
                cell.cafeSort.text = String(seat)
            }
            break
        case .tasty:
            if let tasty = currentCafes.tasty {
                cell.cafeSort.text = String(tasty)
            }
            break
        case .quiet:
            if let quiet = currentCafes.quiet {
                cell.cafeSort.text = String(quiet)
            }
            break
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
