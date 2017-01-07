//
//  CityMenuTableViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/7.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class CityMenuTableViewController: UITableViewController {

    var city = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 5 }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.superview?.layer.cornerRadius = 0.0
        self.preferredContentSize = CGSize(width: 120, height: 220)
    }
    
    @IBAction func selectCity(_ sender: UIButton) {
        
        switch sender.tag {
            
        case 0:
            self.city = "taipei"
        case 1:
            self.city = "hsinchu"
        case 2:
            self.city = "taichung"
        case 3:
            self.city = "tainan"
        case 4:
            self.city = "quiet"
        default :
            self.city = "kaohsiung"
        }
        self.performSegue(withIdentifier: "backToCafeDetail", sender: self)
    }
}
