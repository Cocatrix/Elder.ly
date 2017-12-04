//
//  StringUtils.swift
//  Elder.ly
//
//  Created by Arnaud on 04/12/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{2})(\\d{2})(\\d{2})(\\d{2})(\\d{2})", with: "$1 $2 $3 $4 $5", options: .regularExpression, range: nil)
    }
}
