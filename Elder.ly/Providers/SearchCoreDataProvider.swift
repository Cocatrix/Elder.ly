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
    
    func getSearchPredicate(content: String) -> NSPredicate? {
        /**
         * Returns a predicate that filters the results with data corresponding to "content"
         * Filters contacts matching "content" in their first/last names, phone numbers or emails.
         */
        guard content != "" else {
            print("Search error")
            return nil
        }
        let predicateContent = "(firstName CONTAINS[cd] %@) || (lastName CONTAINS[cd] %@) || (phone CONTAINS[cd] %@) || (email CONTAINS[cd] %@)"
        let searchPredicate: NSPredicate
        searchPredicate = NSPredicate(format: predicateContent, content, content, content, content)
        return searchPredicate
    }
    
    func getFavouritePredicate() -> NSPredicate? {
        /**
         * Returns a predicate that filters the results with favourite contacts
         */
        let predicateContent = "firstName == %@"
        let searchPredicate: NSPredicate
        searchPredicate = NSPredicate(format: predicateContent, "true")
        return searchPredicate
    }
}
