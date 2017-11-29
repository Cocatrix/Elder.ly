//
//  MasterViewController.swift
//  Elder.ly
//
//  Created by Maxime REVEL on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var resultController: NSFetchedResultsController<Contact>?
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil // Called by AppDelegate. But useful ?

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        /*
         * Handle navigation bar :
         *  Left : Edit // TODO - Burger menu instead
         *  Right : Add button, linked to "insertNewObject()"
         */
        navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Use WebService to identify and load data
        let wsProvider = WebServicesProvider.sharedInstance
        
        // Fake login to test list printing
        DispatchQueue.global(qos: .background).async {
            wsProvider.userLogin(phone: "0600000042", password: "0000", success: {
                print("Fake login : success")
                // Load contacts in local DB
                wsProvider.getContacts(success: {
                    print("Load data : success")
                    DispatchQueue.main.async {
                        print("Reloading data")
                        self.tableView.reloadData()
                    }
                }, failure: { (error) in
                    print(error ?? "unknown error")
                })
            }, failure: { (error) in
                print(wsProvider.token ?? "notoken")
            })
        }
        
        // Setup fetched resultController
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        // Sort by first name, then by last name
        fetchRequest.sortDescriptors = [sortFirstName, sortLastName]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: self.appDelegate().persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        print("Trying to perform fetch")
        try? frc.performFetch()
        print("Fetch done")
        self.resultController = frc
        self.tableView.reloadData() // Should not be useful
    }

    override func viewWillAppear(_ animated: Bool) {
        // TODO - clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        // It is related to selected element. Should it still be selected on viewWillAppear ? I think it's not important to comment it for now.
        super.viewWillAppear(animated)
        
        //TODO: Check if User is Connected
        var isUserConnected = true
        
        if !isUserConnected {
            let controller = LoginViewController(nibName: nil, bundle: nil)
            
            self.present(controller, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.resultController?.managedObjectContext
        
        // Use WebService to identify and load data
        let wsProvider = WebServicesProvider.sharedInstance
        wsProvider.createContactOnServer(email: "xxx@example.com", phone: "0647474747", firstName: "Dad", lastName: "Kennedy", profile: "MEDECIN", gravatar: "", isFamilinkUser: false, isEmergencyUser: false, success: {
            print("Create contact : success")
         }, failure: { (error) in
            print(error ?? "unknown error")
         })
        
        // Save the context.
        do {
            try context?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Called prepare")
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = resultController?.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        print("Called numberOfSections")
        if let frc = self.resultController {
            return frc.sections!.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Called numberOfRowsInSection")
        guard let sections = self.resultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        print("Number of objects : ", sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Called cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let contact = resultController?.object(at: indexPath)
        print("Configuring cell at index : ", indexPath)
        // Displaying with grey background on half cells
        if (indexPath.row+1)%2 == 0 {
            cell.contentView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
        configureCell(cell, withContact: contact!)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        print("Called canEditRowAt")
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("Called UITableViewCellEditingStyle")
        if editingStyle == .delete {
            let context = self.resultController?.managedObjectContext
            context?.delete((self.resultController?.object(at: indexPath))!)
                
            do {
                try context?.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withContact contact: Contact) {
        print("Called configureCell")
        cell.textLabel!.text = contact.firstName
    }
    /*
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
     */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("Inserting ? : ", type)
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
         print("Updating ? : ", type)
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withContact: anObject as! Contact)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withContact: anObject as! Contact)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    /*
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    */
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
}

extension MasterViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Did change content")
        self.tableView.reloadData()
    }
    
}

