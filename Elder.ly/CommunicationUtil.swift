//
//  CommunicationUtil.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 30/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

class CommunicationUtil {
    static func call(phoneNumber: String) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "tel://\(phoneNumber)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "tel://\(phoneNumber)")!)
        }
    }
    
    static func text(phoneNumber: String) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "sms:\(phoneNumber)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "sms:\(phoneNumber)")!)
        }
    }
    
    static func email(emailAdress: String) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "mailto://\(emailAdress)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto://\(emailAdress)")!)
        }
    }
}
