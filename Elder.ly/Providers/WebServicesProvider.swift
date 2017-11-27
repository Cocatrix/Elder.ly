//
//  WebServicesProvider.swift
//  Elder.ly
//
//  Created by Arnaud on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

private let sharedWebServices = WebServicesProvider()

class WebServicesProvider {
    var token: String?
    let url: String = "http://familink.cleverapps.io"
    
    class var sharedInstance: WebServicesProvider {
        return sharedWebServices
    }
    
    func userLogin(phone: String, password: String) {
        let url = URL(string: self.url + "/public/login")
        var request = URLRequest(url: url!)
        let login: [String: String] = ["phone": phone, "password": password]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: login, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            let jsonDict = try? JSONSerialization.jsonObject(with:
                data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
            guard let dict = jsonDict as? [String: Any] else {
                return
            }
            self.token = dict["token"] as? String
            print(self.token ?? "no token")
        }
        task.resume()
    }
    
    
    
    
}

