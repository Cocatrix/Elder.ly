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
    static let DATA_ERROR: Int = -1
    static let AUTH_ERROR: Int = -2
    static let NETWORK_ERROR: Int = -3
    
    let persistentContainer: NSPersistentContainer
    let url: String = "http://familink.cleverapps.io"
    var token: String?
    
    class var sharedInstance: WebServicesProvider {
        return sharedWebServices
    }
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        persistentContainer = appDelegate.persistentContainer
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func revokeToken() {
        token = nil
    }
    
    func userLogin(phone: String, password: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        let url = URL(string: self.url + "/public/login")
        var request = URLRequest(url: url!)
        let login: [String: String] = ["phone": phone, "password": password]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: login, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpError = self.checkForHTTPError(response: response) {
                failure(httpError)
                return
            }
            self.checkForDataError(data: data, success: { (dict) in
                self.token = dict["token"] as? String
                success()
            }, failure: { (error) in
                failure(error)
            })
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
            if let httpError = self.checkForHTTPError(response: response) {
                failure(httpError)
                return
            }
            success()
        }
        task.resume()
    }
    
    func getCurrentUser(success: @escaping (User) -> (), failure: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { (context) in
            guard let token = self.token else {
                failure(NSError(domain: "Auth Error", code: WebServicesProvider.AUTH_ERROR, userInfo: nil))
                return
            }
            let url = URL(string: self.url + "/secured/users/current")
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpError = self.checkForHTTPError(response: response) {
                    failure(httpError)
                    return
                }
                self.checkForDataError(data: data, success: { (userDict) in
                    let fetchRequest = NSFetchRequest<User>(entityName: "User")
                    let users = try! context.fetch(fetchRequest)
                    var myUser: User
                    if let user = users.first {
                        myUser = user
                    } else {
                        myUser = User(entity: User.entity(), insertInto: context)
                    }
                    self.updateLocalUser(user: myUser, dict: userDict)
                    do {
                        try context.save()
                        success(myUser)
                    } catch {
                        failure(error)
                    }
                }, failure: { (error) in
                    failure(error)
                })
            }
            task.resume()
        }
    }
    
    func forgottenPassword(phone: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        let url = URL(string: self.url + "/public/forgot-password")
        var request = URLRequest(url: url!)
        let phoneNumber: [String: String] = ["phone": phone]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: phoneNumber, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpError = self.checkForHTTPError(response: response) {
                failure(httpError)
                return
            }
            success()
        }
        task.resume()
    }
    
    func getContacts(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        guard let token = self.token else {
            failure(NSError(domain: "Auth Error", code: WebServicesProvider.AUTH_ERROR, userInfo: nil))
            return
        }
        let url = URL(string: self.url + "/secured/users/contacts")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("task initialized")
            if let httpError = self.checkForHTTPError(response: response) {
                failure(httpError)
                return
            }
            guard let data = data else {
                failure(NSError(domain:"Data Error", code: WebServicesProvider.DATA_ERROR, userInfo: ["Error": "no data"]))
                return
            }
            let jsonDict = try? JSONSerialization.jsonObject(with:
                data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]]
            guard let dict = jsonDict as? [[String: Any]] else {
                failure(NSError(domain:"Data Error", code: WebServicesProvider.DATA_ERROR, userInfo: ["Error": "Invalid data"]))
                return
            }
            self.updateLocalData(jsonDict: dict, success: {
                success()
            }, failure: { (error) in
                failure(error)
            })
        }
        task.resume()
    }
    
    func updateLocalData (jsonDict: [[String: Any]], success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
            let contacts = try! context.fetch(fetchRequest)
            let contactIds = contacts.map({ (contact) -> String in
                return contact.wsId!
            })
            let serverIds = jsonDict.map { (dict) -> String in
                return dict["_id"] as? String ?? "ERROR"
            }
            // Delete data that is not on server
            for contact in contacts {
                if !serverIds.contains(contact.wsId!) {
                    context.delete(contact)
                }
            }
            // Update or create contact
            for jsonContact in jsonDict {
                if contactIds.contains(jsonContact["_id"] as! String) {
                    let currentContact = contacts.filter({return jsonContact["_id"] as? String == $0.wsId}).first
                    self.updateLocalContactWithData(contact: currentContact!, dict: jsonContact)
                } else {
                    let contact = Contact(context: context)
                    contact.wsId = jsonContact["_id"] as? String ?? "Error"
                    contact.isFavouriteUser = false
                    contact.frequency = 0
                    self.updateLocalContactWithData(contact: contact, dict: jsonContact)
                }
            }
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
    
    func createContactOnServer(email: String, phone: String, firstName: String, lastName: String,
                               profile: String, gravatar: String, isFamilinkUser: Bool, isEmergencyUser: Bool, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { (context) in
            guard let token = self.token else {
                failure(NSError(domain: "Auth Error", code: WebServicesProvider.AUTH_ERROR, userInfo: nil))
                return
            }
            let jsonContact: [String: Any] = ["email": email, "phone": phone, "firstName": firstName, "lastName": lastName, "profile": profile, "gravatar": gravatar, "isFamilinkUser": isFamilinkUser, "isEmergencyUser": isEmergencyUser]
            let url = URL(string: self.url + "/secured/users/contacts")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonContact, options: .prettyPrinted)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpError = self.checkForHTTPError(response: response) {
                    failure(httpError)
                    return
                }
                self.checkForDataError(data: data, success: { (dict) in
                    let contact = Contact(entity: Contact.entity(), insertInto: context)
                    contact.wsId = dict["_id"] as? String
                    contact.isFavouriteUser = false
                    contact.frequency = 0
                    self.updateLocalContactWithData(contact: contact, dict: dict)
                    do {
                        try context.save()
                    } catch {
                        failure(error)
                        return
                    }
                    success()
                }, failure: { (error) in
                    failure(error)
                })
            }
            task.resume()
        }
    }
    
    func updateContactOnServer(wsId: String, email: String, phone: String, firstName: String, lastName: String,
                               profile: String, gravatar: String, isFamilinkUser: Bool, isEmergencyUser: Bool, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { (context) in
            guard let token = self.token else {
                failure(NSError(domain: "Auth Error", code: WebServicesProvider.AUTH_ERROR, userInfo: nil))
                return
            }
            let jsonContact: [String: Any] = ["email": email, "phone": phone, "firstName": firstName, "lastName": lastName, "profile": profile,
                                              "gravatar": gravatar, "isFamilinkUser": isFamilinkUser, "isEmergencyUser": isEmergencyUser, "_id": wsId]
            let url = URL(string: self.url + "/secured/users/contacts/\(wsId)")
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonContact, options: .prettyPrinted)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpError = self.checkForHTTPError(response: response) {
                    failure(httpError)
                    return
                }
                let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
                let contacts = try! context.fetch(fetchRequest)
                let contact = contacts.filter({return jsonContact["_id"] as? String == $0.wsId}).first
                guard let contactToUpdateLocally = contact else {
                    print("Filtering contact not working")
                    return
                }
                contactToUpdateLocally.wsId = wsId
                self.updateLocalContactWithData(contact: contactToUpdateLocally, dict: jsonContact)
                do {
                    try context.save()
                    success()
                } catch {
                    failure(error)
                }
            }
            task.resume()
        }
    }
    
    func deleteContactOnServer(wsId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { (context) in
            guard let token = self.token else {
                failure(NSError(domain: "Auth Error", code: WebServicesProvider.AUTH_ERROR, userInfo: nil))
                return
            }
            let url = URL(string: self.url + "/secured/users/contacts/\(wsId)")
            var request = URLRequest(url: url!)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpError = self.checkForHTTPError(response: response) {
                    failure(httpError)
                    return
                }
                let sort = NSSortDescriptor(key: "lastName", ascending: true)
                let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
                fetchRequest.sortDescriptors = [sort]
                let contacts = try! context.fetch(fetchRequest)
                let contact = contacts.filter({return wsId == $0.wsId}).first
                if let contact = contact {
                    context.delete(contact)
                }
                do {
                    try context.save()
                    success()
                } catch {
                    failure(error)
                    return
                }
            }
            task.resume()
        }
    }
    
    func getProfiles(success: @escaping ([String]) -> (), failure: @escaping (Error?) -> ()) {
        let url = URL(string: self.url + "/public/profiles")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("task initialized")
            if let httpError = self.checkForHTTPError(response: response) {
                failure(httpError)
                return
            }
            guard let data = data else {
                failure(NSError(domain:"Data Error", code: WebServicesProvider.DATA_ERROR, userInfo: ["Error": "no data"]))
                return
            }
            let jsonDict = try? JSONSerialization.jsonObject(with:
                data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String]
            guard let dict = jsonDict as? [String] else {
                failure(NSError(domain:"Data Error", code: WebServicesProvider.DATA_ERROR, userInfo: ["Error": "Invalid data"]))
                return
            }
            success(dict)
        }
        task.resume()
    }
    
    func checkForHTTPError(response: URLResponse?) -> (Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
                if httpResponse.statusCode == 401 {
                    return NSError(domain: "Auth Error", code: WebServicesProvider.AUTH_ERROR, userInfo: nil)
                } else {
                    return NSError(domain:"HTTP Error", code: httpResponse.statusCode, userInfo:nil)
                }
            } else {
                return nil
            }
        } else {
            return NSError(domain:"Network Error", code: WebServicesProvider.NETWORK_ERROR, userInfo:nil)
        }
    }
    
    func checkForDataError(data: Data?, success: @escaping ([String: Any]) -> (), failure: @escaping (Error?) -> ()) {
        guard let data = data else {
            failure(NSError(domain:"Data Error", code: WebServicesProvider.DATA_ERROR, userInfo: ["Error": "no data"]))
            return
        }
        let jsonDict = try? JSONSerialization.jsonObject(with:
            data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
        guard let dict = jsonDict as? [String: Any] else {
            failure(NSError(domain:"Data Error", code: WebServicesProvider.DATA_ERROR, userInfo: ["Error": "Invalid data"]))
            return
        }
        success(dict)
    }
    
    func updateLocalContactWithData(contact: Contact, dict: [String: Any]) {
        contact.email = dict["email"] as? String
        contact.phone = dict["phone"] as? String
        contact.firstName = dict["firstName"] as? String
        contact.lastName = dict["lastName"] as? String
        contact.profile = dict["profile"] as? String
        contact.gravatar = dict["gravatar"] as? String
        contact.isFamilinkUser = dict["isFamilinkUser"] as? Bool ?? false
        contact.isEmergencyUser = dict["isEmergencyUser"] as? Bool ?? false
    }
    
    func updateLocalUser(user: User, dict: [String: Any]) {
        user.email = dict["email"] as? String
        user.firstName = dict["firstName"] as? String
        user.lastName = dict ["lastName"] as? String
        user.profile = dict["profile"] as? String
        user.phone = dict["phone"] as? String
    }
}
