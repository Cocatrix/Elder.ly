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
    
    func searchContact(content: String) -> [Contact] {
        var matchingContacts = [Contact]()
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let contacts = try! context.fetch(fetchRequest)
        for contact in contacts {
            if ((contact.firstName?.lowercased().range(of: content)) != nil) || ((contact.lastName?.lowercased().range(of: content)) != nil) || ((contact.phone?.range(of: content)) != nil) || ((contact.email?.lowercased().range(of: content)) != nil) {
                matchingContacts.append(contact)
            }
        }
        return matchingContacts
    }
    
}

