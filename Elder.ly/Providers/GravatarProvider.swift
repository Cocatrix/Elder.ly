//
//  GravatarProvider.swift
//  Elder.ly
//
//  Created by Arnaud on 30/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var md5: String! {
        let trimmedString = lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        let utf8String = trimmedString.cString(using: String.Encoding.utf8)!
        let stringLength = CC_LONG(trimmedString.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        
        CC_MD5(utf8String, stringLength, result)
        var hash = ""
        for i in 0..<digestLength {
            hash += String(format: "%02x", result[i])
        }
        result.deallocate(capacity: digestLength)
        return String(format: hash)
    }
}

public class Gravatar {
    public enum Size: CGFloat {
        case small = 80
        case medium = 128
        case large = 200
    }
    
    private static let baseURL = URL(string: "https://secure.gravatar.com/avatar")!
    public let email: String
    
    public init(email: String)
    {
        self.email = email
    }
    
    public static func urlForSize(email: String, size: Size) -> URL {
        let myGrav = Gravatar(email: email)
        return myGrav.url(size: size.rawValue)
    }
    
    func url(size: CGFloat) -> URL {
        let url = Gravatar.baseURL.appendingPathComponent(email.md5)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        components.queryItems = [URLQueryItem(name: "d", value: "retro"), URLQueryItem(name: "s", value: String(format: "%.0f",size))]
        
        return components.url!
    }
}

extension UIImageView {
    public func imageFromServerURL(url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
        }).resume()
    }
    
    public func gravatarImage(email: String, size: Gravatar.Size = Gravatar.Size.medium) {
        let myGrav = Gravatar(email: email)
        imageFromServerURL(url: myGrav.url(size: size.rawValue))
    }
}


