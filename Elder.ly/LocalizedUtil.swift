//
//  LocalizedUtil.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 30/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
