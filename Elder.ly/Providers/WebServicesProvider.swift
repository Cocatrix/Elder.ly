//
//  WebServicesProvider.swift
//  Elder.ly
//
//  Created by Arnaud on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//
import Foundation
import CoreData

private let sharedWebServices = WebServicesProvider()

class WebServicesProvider {
    var token: String?
    let url: String = "http://familink.cleverapps.io"
    
    class var sharedInstance: WebServicesProvider {
        return sharedWebServices
    }
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        persistentContainer = appDelegate.persistentContainer
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func userLogin(phone: String, password: String, callback: @escaping () -> ()) {
        let url = URL(string: self.url + "/public/login")
        var request = URLRequest(url: url!)
        let login: [String: String] = ["phone": phone, "password": password]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: login, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            let jsonDict = try? JSONSerialization.jsonObject(with:
                data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
            guard let dict = jsonDict as? [String: Any] else {
                return
            }
            self.token = dict["token"] as? String
            callback()
        }
        task.resume()
    }
    
    func getContacts() {
        guard let token = self.token else {
            return
        }
        let url = URL(string: self.url + "/secured/users/contacts")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("task initialized")
            guard let data = data else {
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    return
                }
            }
            let jsonDict = try? JSONSerialization.jsonObject(with:
                data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]]
            guard let dict = jsonDict as? [[String: Any]] else {
                return
            }
            self.updateLocalData(jsonDict: dict)
            
        }
        task.resume()
    }
    
    func updateLocalData (jsonDict: [[String: Any]]) {
        
        
        
        
        // let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        
        
        // Update or create
        
        
        
        persistentContainer.performBackgroundTask { (context) in
            let sort = NSSortDescriptor(key: "lastName", ascending: true)
            let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
            fetchRequest.sortDescriptors = [sort]
            let contacts = try! context.fetch(fetchRequest)
            let contactIds = contacts.map({ (contact) -> String in
                return contact.wsId!
            })
            let serverIds = jsonDict.map { (dict) -> String in
                return dict["_id"] as? String ?? "ERROR"
            }
            // Delete data that is not on server
            for contact in contacts {
                if serverIds.contains(contact.wsId!) {
                    context.delete(contact)
                }
            }
            
            for jsonContact in jsonDict {
                if contactIds.contains(jsonContact["_id"] as! String) {
                    print("Contact already exists")
                } else {
                    let contact = Contact(context: context)
                    contact.email = jsonContact["email"] as? String ?? "ERROR"
                    contact.phone = jsonContact["phone"] as? String ?? "ERROR"
                    contact.firstName = jsonContact["firstName"] as? String ?? "ERROR"
                    contact.lastName = jsonContact["lastName"] as? String ?? "ERROR"
                    contact.profile = jsonContact["profile"] as? String ?? "ERROR"
                    contact.gravatar = jsonContact["gravatar"] as? String ?? "ERROR"
                    contact.isFamilinkUser = jsonContact["isFamilinkUser"] as? Bool ?? false
                    contact.isEmergencyUser = jsonContact["isEmergencyUser"] as? Bool ?? false
                    contact.wsId = jsonContact["_id"] as? String ?? "Error"
                    print("added contact \(jsonContact["lastName"] as? String ?? "Error")")
                }
            }
            do {
                if context.hasChanges {
                    
                    try context.save()
                    
                }
            } catch {
                print(error)
                
                
            }
        }
        
        
    }
    
}

