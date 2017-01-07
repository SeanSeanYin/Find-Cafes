//
//  SortTableViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class SortTableViewController: UITableViewController {

    var sortItem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.superview?.layer.cornerRadius = 0.0
        self.preferredContentSize = CGSize(width: 120, height: 220)
    }
    
    @IBAction func selectSortItem(_ sender:UIButton) {
    
        switch sender.tag {
            
            case 0:
                self.sortItem = "wifi"
            case 1:
                self.sortItem = "music"
            case 2:
                self.sortItem = "seat"
            case 3:
                self.sortItem = "tasty"
            case 4:
                self.sortItem = "quiet"
            default :
                self.sortItem = "wifi"
        }        
        self.performSegue(withIdentifier: "backToCafeDetail", sender: self)
    }
}
