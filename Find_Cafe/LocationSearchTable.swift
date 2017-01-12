//
//  LocationSearchTable.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/8.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var addressLabel:UILabel!
}

class LocationSearchTable: UITableViewController {
    
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [CafeInfo] = []
    var cafes:[CafeInfo]!
    var mapView: MKMapView? = nil
    
}

extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text, (self.cafes != nil) else {
            
            print("self.cafes is nil")
            return
        }

        matchingItems = self.cafes.filter { term in
            return (term.name.contains(searchBarText) || term.address.contains(searchBarText))}
        
        self.tableView.reloadData()
    }
}

extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return matchingItems.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchResultsTableViewCell
        let selectedItem = matchingItems[indexPath.row]
        cell.nameLabel.text = selectedItem.name
        cell.addressLabel.text = selectedItem.address
        
        return cell
    }
    
}

extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexPath.row:\(indexPath.row)")
        print("matchingItems.count:\(matchingItems.count)")
        let selectedItem = matchingItems[indexPath.row]
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
}
