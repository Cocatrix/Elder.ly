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
            // No content, a nil predicate is needed.
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
        let favouritePredicate: NSPredicate
        favouritePredicate = NSPredicate(format: "isFavouriteUser == true")
        return favouritePredicate
    }
    
    func getDefaultSortDescriptor() -> [NSSortDescriptor] {
        /**
         * Returns a sort descriptor array with these sort rules :
         * Sort by first name, then by last name
         */
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        return [sortFirstName, sortLastName]
    }
    
    func getFrequentSortDescriptor() -> [NSSortDescriptor] {
        /**
         * Returns a sort descriptor array with these sort rules :
         * Sort by frequency, then by first name, then by last name
         */
        let sortFrequency = NSSortDescriptor(key: "frequency", ascending: false)
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        return [sortFrequency, sortFirstName, sortLastName]
    }
}
