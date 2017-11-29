//
//  UserValidationUtil.swift
//  Elder.ly
//
//  Created by Thibault Goudouneix on 29/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

class UserValidationUtil {
    static func validatePhone(phone: String) -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: phone, options: [], range: NSMakeRange(0, phone.count))
            if let res = matches.first {
                let result = res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phone.count
                print("Phone OK")
                return result
            } else {
                print("Phone not OK")
                return false
            }
        } catch {
            print(error)
        }
        return false;
    }
    
    static func validateFirstname(firstname: String) -> Bool {
        let result = firstname.count > 0
        if (result) {
            print("Firstname OK")
        } else {
            print("Firstname not OK")
        }
        return result
    }
    
    static func validateLastname(lastname: String) -> Bool {
        let result = lastname.count > 0
        if (result) {
            print("Lastname OK")
        } else {
            print("Lastname not OK")
        }
        return result
    }
    
    static func validateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        if (result) {
            print("Email OK")
        } else {
            print("Email not OK")
        }
        return result
    }
    
    static func validateProfile(profile: String) -> Bool {
        return false;
    }
}
