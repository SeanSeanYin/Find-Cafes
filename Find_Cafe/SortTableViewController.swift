//
//  SortTableViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/21.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class SortTableViewController: UITableViewController {

    var sort = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 6 }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.superview?.layer.cornerRadius = 0.0
        self.preferredContentSize = CGSize(width: 80, height: 264)
    }
    
    @IBAction func selectSortItem(_ sender: UIButton) {
        
        switch sender.tag {
            
            case 0:
                self.sort = "wifi"
            case 1:
                self.sort = "seat"
            case 2:
                self.sort = "quiet"
            case 3:
                self.sort = "tasty"
            case 4:
                self.sort = "cheap"
            case 5:
                self.sort = "music"
            default :
                self.sort = "wifi"
        }

        self.performSegue(withIdentifier: "backToCafeDetail", sender: self)
    }
}
