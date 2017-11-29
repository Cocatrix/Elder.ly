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
         * Works with firstName only.
         * TODO - Find a way to tell predicate : (firstName CONTAINS X) OR (lastName CONTAINS X) OR ... (with firstName, lastName, phone, email)
         */
        let searchPredicate: NSPredicate
        guard content != "" else {
            print("Search error")
            return NSPredicate() // TODO - Find better catching
        }
        searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@", content)
        return searchPredicate
    }
}
