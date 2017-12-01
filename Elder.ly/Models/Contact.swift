//
//  Contact.swift
//  Elder.ly
//
//  Created by Arnaud on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation
import CoreData

extension Contact {
    
    private func getPersistentContainer() -> NSPersistentContainer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return persistentContainer
    }
    
    func updateIsFavouriteContact(shouldBeFavourite: Bool, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        /**
         * Make asynchronous task of updating the boolean "isFavouriteUser" of current contact.
         * Fetches all contacts, get the right one from context, updates its bool with parameter "shouldBeFavourite", and saves context.
         */
        self.getPersistentContainer().performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
            let contacts = try! context.fetch(fetchRequest)
            let coreContactArray = contacts.filter({ (existingContact) -> Bool in
                existingContact.wsId == self.wsId
            })
            guard coreContactArray.count == 1 else {
                print("Not found contacts; or several contacts with same Id")
                return
            }
            let coreContact = coreContactArray[0]
            coreContact.isFavouriteUser = shouldBeFavourite
            do {
                if context.hasChanges {
                    try context.save()
                    success()
                }
            } catch {
                failure(error)
                return
            }
        }
    }
}
