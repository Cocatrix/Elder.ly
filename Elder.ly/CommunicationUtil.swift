//
//  CommunicationUtil.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 30/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

class CommunicationUtil {
    static func call(phoneNumber: String, contact: Contact) {
        let frequency = contact.frequency
        // Calling : frequency + 2
        contact.updateContactFrequency(newFrequency: frequency + 2, success: {
            print("Calling ", phoneNumber, " : Frequency updated")
        }, failure: { (error) in
            print("Calling ", phoneNumber, " : Frequency not updated")
        })
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "tel://\(phoneNumber)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "tel://\(phoneNumber)")!)
        }
    }
    
    static func text(phoneNumber: String, contact: Contact) {
        let frequency = contact.frequency
        // Texting : frequency + 1
        contact.updateContactFrequency(newFrequency: frequency + 1, success: {
            print("Texting ", phoneNumber, " : Frequency updated")
        }, failure: { (error) in
            print("Texting ", phoneNumber, " : Frequency not updated")
        })
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "sms:\(phoneNumber)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "sms:\(phoneNumber)")!)
        }
    }
    
    static func email(emailAdress: String, contact: Contact) {
        let frequency = contact.frequency
        // Emailing : frequency + 1
        contact.updateContactFrequency(newFrequency: frequency + 1, success: {
            print("Emailing ", email, " : Frequency updated")
        }, failure: { (error) in
            print("Emailing ", email, " : Frequency not updated")
        })
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "mailto://\(emailAdress)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto://\(emailAdress)")!)
        }
    }
}
