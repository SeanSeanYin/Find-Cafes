//
//  SelectCityViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/29.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class SelectCityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseCityToSearch(sender: UIButton!) {
        
        guard let city = sender.currentTitle else {
            print("Failed to get city")
            return
        }
        
        let alert = UIAlertController(title: "You select \(city) city", message: "Are you sure?", preferredStyle: .alert)
        let doAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.performSegue(withIdentifier: "chooseCityToSearch", sender: sender)
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(doAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "chooseCityToSearch") {
            
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! CafesViewController
            viewController.selectedCity = (sender as! UIButton).currentTitle!
        }
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
