//
//  SearchCoreDataProvider.swift
//  Elder.ly
//
//  Created by Arnaud on 29/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation
import CoreData

private let sharedSearchCoreData = SearchCoreDataProvider()

class SearchCoreDataProvider {
    let persistentContainer: NSPersistentContainer
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.persistentContainer = appDelegate.persistentContainer
    }
    
    class var sharedInstance: SearchCoreDataProvider {
        return sharedSearchCoreData
    }
    
    func getSearchPredicate(content: String) -> NSPredicate {
        /**
         * Returns a predicate that filters the results with data corresponding to "content"
         * Filters contacts matching "content" in their first/last names, phone numbers or emails.
         */
        guard content != "" else {
            print("Search error")
            return NSPredicate() // TODO - Find better catching
        }
        let predicateContent = "(firstName CONTAINS[c] %@) || (lastName CONTAINS[c] %@) || (phone CONTAINS[c] %@) || (email CONTAINS[c] %@)"
        let searchPredicate: NSPredicate
        searchPredicate = NSPredicate(format: predicateContent, content, content, content, content)
        return searchPredicate
    }
}
