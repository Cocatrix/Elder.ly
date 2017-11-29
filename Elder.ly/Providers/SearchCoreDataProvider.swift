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
    
    func searchContact(content: String) -> NSPredicate {
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "firstName CONTAINS[c] %@", content)
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        // Sort by first name, then by last name
        fetchRequest.sortDescriptors = [sortFirstName, sortLastName]
        /*
         An idea of the fields to look at :
         
         if ((contact.firstName?.lowercased().range(of: content)) != nil) || ((contact.lastName?.lowercased().range(of: content)) != nil) || ((contact.phone?.range(of: content)) != nil) || ((contact.email?.lowercased().range(of: content)) != nil) {
         */
        return fetchRequest.predicate!
    }
}
