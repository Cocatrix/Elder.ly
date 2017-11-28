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
    
    func createUser(phone: String, password: String, firstName: String, lastName: String, email: String, profile: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        let url = URL(string: self.url + "/public/sign-in?contactsLength=0")
        var request = URLRequest(url: url!)
        let jsonUser: [String: String] = ["phone": phone, "password": password, "firstName": firstName, "lastName": lastName, "email": email, "profile": profile]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonUser, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    success()
                } else {
                    failure(NSError(domain:"HTTP Error", code: httpResponse.statusCode, userInfo:nil))
                }
            } else {
                failure(error)
            }
        }
        task.resume()
    }
    
    func forgottenPassword(phone: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        let url = URL(string: self.url + "/public/forgot-password")
        var request = URLRequest(url: url!)
        let phoneNumber: [String: String] = ["phone": phone]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: phoneNumber, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    success()
                } else {
                    failure(NSError(domain:"HTTP Error", code: httpResponse.statusCode, userInfo:nil))
                }
            } else {
                failure(error)
            }
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
            // Update or create contact
            for jsonContact in jsonDict {
                if contactIds.contains(jsonContact["_id"] as! String) {
                    let currentContact = contacts.filter({return jsonContact["_id"] as? String == $0.wsId}).first
                    currentContact?.email = jsonContact["email"] as? String ?? "ERROR"
                    currentContact?.phone = jsonContact["phone"] as? String ?? "ERROR"
                    currentContact?.firstName = jsonContact["firstName"] as? String ?? "ERROR"
                    currentContact?.lastName = jsonContact["lastName"] as? String ?? "ERROR"
                    currentContact?.profile = jsonContact["profile"] as? String ?? "ERROR"
                    currentContact?.gravatar = jsonContact["gravatar"] as? String ?? "ERROR"
                    currentContact?.isFamilinkUser = jsonContact["isFamilinkUser"] as? Bool ?? false
                    currentContact?.isEmergencyUser = jsonContact["isEmergencyUser"] as? Bool ?? false
                    print("updated contact \(jsonContact["lastName"] as? String ?? "Error")")
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
    
    func createContactOnServer(email: String, phone: String, firstName: String, lastName: String,
                               profile: String, gravatar: String, isFamilinkUser: Bool, isEmergencyUser: Bool) {
        persistentContainer.performBackgroundTask { (context) in
            guard let token = self.token else {
                return
            }
            let jsonContact: [String: Any] = ["email": email, "phone": phone, "firstName": firstName, "lastName": lastName, "profile": profile,
                                              "gravatar": gravatar, "isFamilinkUser": isFamilinkUser, "isEmergencyUser": isEmergencyUser]
            let url = URL(string: self.url + "/secured/users/contacts")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonContact, options: .prettyPrinted)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    return
                }
                let jsonDict = try? JSONSerialization.jsonObject(with:
                    data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                guard let dict = jsonDict as? [String: Any] else {
                    return
                }
                let contact = Contact(entity: Contact.entity(), insertInto: context)
                contact.email = dict["email"] as? String
                contact.phone = dict["phone"] as? String
                contact.firstName = dict["firstName"] as? String
                contact.lastName = dict["lastName"] as? String
                contact.profile = dict["profile"] as? String
                contact.gravatar = dict["gravatar"] as? String
                contact.isFamilinkUser = dict["isFamilinkUser"] as? Bool ?? false
                contact.isEmergencyUser = dict["isEmergencyUser"] as? Bool ?? false
                contact.wsId = dict["_id"] as? String
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    func updateContactOnServer(wsId: String, email: String, phone: String, firstName: String, lastName: String,
                               profile: String, gravatar: String, isFamilinkUser: Bool, isEmergencyUser: Bool) {
        persistentContainer.performBackgroundTask { (context) in
            guard let token = self.token else {
                return
            }
            let jsonContact: [String: Any] = ["email": email, "phone": phone, "firstName": firstName, "lastName": lastName, "profile": profile,
                                              "gravatar": gravatar, "isFamilinkUser": isFamilinkUser, "isEmergencyUser": isEmergencyUser]
            let url = URL(string: self.url + "/secured/users/contacts/\(wsId)")
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonContact, options: .prettyPrinted)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    return
                }
                let jsonDict = try? JSONSerialization.jsonObject(with:
                    data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                guard let dict = jsonDict as? [String: Any] else {
                    return
                }
                let sort = NSSortDescriptor(key: "lastName", ascending: true)
                let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
                fetchRequest.sortDescriptors = [sort]
                let contacts = try! context.fetch(fetchRequest)
                let contact = contacts.filter({return jsonContact["_id"] as? String == $0.wsId}).first
                contact?.email = dict["email"] as? String
                contact?.phone = dict["phone"] as? String
                contact?.firstName = dict["firstName"] as? String
                contact?.lastName = dict["lastName"] as? String
                contact?.profile = dict["profile"] as? String
                contact?.gravatar = dict["gravatar"] as? String
                contact?.isFamilinkUser = dict["isFamilinkUser"] as? Bool ?? false
                contact?.isEmergencyUser = dict["isEmergencyUser"] as? Bool ?? false
                contact?.wsId = dict["_id"] as? String
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
}

