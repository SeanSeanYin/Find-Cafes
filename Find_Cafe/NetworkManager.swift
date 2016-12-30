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

public func getData(city:String?, completion: @escaping (_ response:DataResponse<Any>) -> Void) throws -> () {
    
    // 確定url不是空白
    guard let cityName = city else {
        throw ApiError.wrongParameters
    }
    
    Alamofire.request(cityName, method: .get, parameters: nil, encoding: URLEncoding.httpBody).validate().responseJSON { responseObject in
        print("URL: \(cityName)")
        switch responseObject.result {
        case .success:
            
            print("Get data successfully.")
            completion(responseObject)
            
        case .failure(let error):
            
            print("error :\(error.localizedDescription)")
            print(responseObject)
        }
    }
}



