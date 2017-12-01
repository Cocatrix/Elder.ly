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

private protocol QueryItemConvertible {
    var queryItem: URLQueryItem {get}
}

public class Gravatar {
    public enum DefaultImage: String, QueryItemConvertible {
        case http404 = "404"
        case mysteryMan = "mm"
        case identicon = "identicon"
        case monsterID = "monsterid"
        case wavatar = "wavatar"
        case retro = "retro"
        case blank = "blank"
        
        var queryItem: URLQueryItem {
            return URLQueryItem(name: "d", value: rawValue)
        }
    }
    
    public enum Rating: String, QueryItemConvertible {
        case g = "g"
        case pg = "pg"
        case r = "r"
        case x = "x"
        
        var queryItem: URLQueryItem {
            return URLQueryItem(name: "r", value: rawValue)
        }
    }
    
    public enum Size: CGFloat {
        case small = 80
        case medium = 128
        case large = 200
    }
    
    private static let baseURL = URL(string: "https://secure.gravatar.com/avatar")!
    public let email: String
    public let forceDefault: Bool
    public let defaultImage: DefaultImage
    public let rating: Rating
    
    public init(
        email: String,
        defaultImage: DefaultImage = .mysteryMan,
        forceDefault: Bool = false,
        rating: Rating = .pg)
    {
        self.email = email
        self.defaultImage = defaultImage
        self.forceDefault = forceDefault
        self.rating = rating
    }
    
    func url(size: CGFloat, scale: CGFloat = UIScreen.main.scale) -> URL {
        let url = Gravatar.baseURL.appendingPathComponent(email.md5)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        var queryItems = [defaultImage.queryItem, rating.queryItem]
        queryItems.append(URLQueryItem(name: "s", value: String(format: "%.0f",size * scale)))
        
        components.queryItems = queryItems
        
        return components.url!
    }
    
    public static func urlForSize(email: String, size: Size = Size.medium) -> URL {
        let myGrav = Gravatar.init(email: email)
        return myGrav.url(size: size.rawValue)
    }
}


