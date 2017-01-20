//
//  NetworkManager.swift
//  Find_Cafe
//
//  Created by Sean on 2016/12/30.
//  Copyright © 2016年 Chien Hsiang Yin. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import MapKit

enum ApiError:Error{
    
    case makeSignatureFail
    case wrongParameters
    case wrongURL
}

struct ApiURL {
    
    static let serverDomain = "https://cafenomad.tw/api/v1.0/cafes/"
    
    enum City:String {
        
        case taipei = "taipei"
        case hsinchu = "hsinchu"
        case taichung = "taichung"
        case tainan  = "tainan"
        case kaohsiung  = "kaohsiung"
        case none = "none"
    }
    
    static func getCity (city:City) -> String {
        
        let apiUrl = self.serverDomain + city.rawValue
        return apiUrl
        
    }
}

public func getData(city:String?, completion: @escaping (_ response:[Any]?, _ err:Error?) -> Void) throws -> () {
    
    var cafes:[CafeInfo]!
    
    // 確定url不是空白
    guard let cityName = city else {
        throw ApiError.wrongURL
    }
    
    let url = "https://cafenomad.tw/api/v1.0/cafes/" + cityName

    Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody).validate().responseJSON { responseObject in

        switch responseObject.result {
        case .success(let value):

            let objArray = JSON(value)
            
            for (_, obj) in objArray {
                
                let id = obj["id"].stringValue
                let name = obj["name"].stringValue
                let url = obj["url"].stringValue
                let city = obj["city"].stringValue
                let address = obj["address"].stringValue
                let wifi = obj["wifi"].doubleValue
                let seat = obj["seat"].doubleValue
                let quiet = obj["quiet"].doubleValue
                let music = obj["music"].doubleValue
                let tasty = obj["tasty"].doubleValue
                let cheap = obj["cheap"].doubleValue
                let location = CLLocationCoordinate2D(latitude: obj["latitude"].doubleValue, longitude: obj["longitude"].doubleValue)
                
                let cafe = CafeInfo(id: id, name: name, url: url, city: city, address: address, wifi: wifi, seat: seat, quiet: quiet, music: music, tasty: tasty, cheap:cheap, location: location)
                
                if cafes == nil {
                    cafes = [CafeInfo]()
                }                    
                cafes.append(cafe)
            }
            
            completion(cafes, nil)
        case .failure(let error):
            completion( cafes, error)
            print("Connection error: \(error.localizedDescription)")
        }
    }
}



