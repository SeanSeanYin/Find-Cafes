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
        
        self.preferredContentSize = CGSize(width: 80, height: 220)
    }
    
    @IBAction func sortBy (sender: UIButton) {
        
        sortItem = String(sender.tag)
        print("sortItem:\(sortItem)")
                
        self.performSegue(withIdentifier: "sortSegue", sender: sortItem)
    }

}
