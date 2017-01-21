//
//  SelectCityTableViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/21.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class SelectCityTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (UIScreen.main.bounds.height *  0.195)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var city = ""
        switch (indexPath.row){
            case 0:
                city = "Taipei"
            case 1:
                city = "Hsinchu"
            case 2:
                city = "Taichung"
            case 3:
                city = "Tainan"
            case 4:
                city = "Kaohsiung"
            default:
                city = "Taipei"
        }
        
        let alert = UIAlertController(title: "You select \(city) city", message: "Are you sure?", preferredStyle: .alert)
        let doAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.performSegue(withIdentifier: "chooseCityToSearch", sender: city)
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(doAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var city = ""
        
        if (segue.identifier == "chooseCityToSearch") {
            
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! CafesViewController
            switch (sender as! String) {
            case "Taipei":
                city = "台北"
            case "Hsinchu":
                city = "新竹"
            case "Taichung":
                city = "台中"
            case "Tainan":
                city = "台南"
            case "Kaohsiung":
                city = "高雄"
            default:
                city = "台北"
            }
            viewController.newCity = city
        }
    }
}
