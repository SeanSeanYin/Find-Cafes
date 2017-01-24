//
//  CityMenuViewController.swift
//  Find_Cafe
//
//  Created by Sean on 2017/1/23.
//  Copyright © 2017年 Chien Hsiang Yin. All rights reserved.
//

import UIKit

class CityMenuTableCell: UITableViewCell {

    @IBOutlet weak var cityImage:UIImageView!
    @IBOutlet weak var cityLabel:UILabel!
}

class CityMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var cityMenuTable:UITableView!
    
    var selectedCity = ""
    var interactor:Interactor? = nil
    var cityMenuDelegate: CityMenuDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityMenuTable.delegate = self
        self.cityMenuTable.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CityMenuTableCell
        switch(indexPath.row){
            case 0:
                cell.cityImage.image = UIImage(named: "btn_taipei_selected_copy")
                cell.cityLabel?.text = "Taipei"
            case 1:
                cell.cityImage.image = UIImage(named: "btn_hsinchu_n")
                cell.cityLabel?.text = "Hsinchu"
            case 2:
                cell.cityImage.image = UIImage(named: "btn_taichung_n")
                cell.cityLabel?.text = "Taichung"
            case 3:
                cell.cityImage.image = UIImage(named: "btn_tainan_n")
                cell.cityLabel?.text = "Tainan"
            case 4:
                cell.cityImage.image = UIImage(named: "btn_kaoshiung_n")
                cell.cityLabel?.text = "Kaoshiung"
            default:
                cell.imageView?.image = UIImage(named: "btn_taipei_selected_copy")
                cell.textLabel?.text = "Taipei"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (UIScreen.main.bounds.height *  0.175)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch (indexPath.row) {
            case 0:
                self.selectedCity = "taipei"
            case 1:
                self.selectedCity = "hsinchu"
            case 2:
                self.selectedCity = "taichung"
            case 3:
                self.selectedCity = "tainan"
            case 4:
                self.selectedCity = "kaohsiung"
            default:
                self.selectedCity = "taipei"
        }
        cityMenuDelegate?.showSelectedCity(city: self.selectedCity)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .left)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeMenu(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true){
            self.delay(seconds: 0.5){
                
            }
        }
    }
}
