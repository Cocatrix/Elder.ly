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
    var managedObjectContext: NSManagedObjectContext? = nil // Called by AppDelegate.

    var currentTabPredicate : NSPredicate?
    var currentSearchPredicate : NSPredicate?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.tabBar.delegate = self
        
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
   
        // Setup fetched resultController
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        // Sort by first name, then by last name
        let scdProvider = SearchCoreDataProvider.sharedInstance
        fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: self.appDelegate().persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        self.resultController = frc
        
        // Select Contacts tab at launch
        guard let items = self.tabBar.items, items.count == 3 else {
            return
        }
        self.tabBar.selectedItem = items[1]
        // TODO - Set toolbar items
    }

    override func viewWillAppear(_ animated: Bool) {
        // TODO - clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        // It is related to selected element. Should it still be selected on viewWillAppear ? I think it's not important to comment it for now.
        super.viewWillAppear(animated)
        
        let isUserConnected = UserDefaults.standard.isAuth()
        
        if !isUserConnected {
            let controller = LoginViewController(nibName: nil, bundle: nil)
            self.present(controller, animated: false, completion: nil)
        }
        
        // Use WebService to identify and load data
        let wsProvider = WebServicesProvider.sharedInstance
        
        wsProvider.getContacts(success: {
            print("Load data : success")
        }, failure: { (error) in
            print(error ?? "unknown error")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let controller = AddEditViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(controller, animated: false)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            print("showDetail")
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = resultController?.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.contact = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = self.resultController {
            return frc.sections!.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let contact = resultController?.object(at: indexPath)
        // Displaying with grey background on half cells
        if (indexPath.row+1)%2 == 0 {
            cell.contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
        configureCell(cell, withContact: contact!)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        if let contactCell = cell as? ContactTableViewCell {
            contactCell.nameLabel.text = (
                contact.firstName! + " " + contact.lastName!)
            if let phone = contact.phone {
                contactCell.setPhoneNumber(phone: phone)
            } else {
                contactCell.callButton.isHidden = true
            }
            if let email = contact.email  {
                contactCell.avatarImageView.gravatarImage(email: email)
            }
        }
    }

    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
}

extension MasterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let frc = self.resultController else {
            return
        }

        let scdProvider = SearchCoreDataProvider.sharedInstance
        // Get predicate corresponding to research
        let searchPredicate = scdProvider.getSearchPredicate(content: searchText)
        self.currentSearchPredicate = searchPredicate
        
        if self.currentTabPredicate != nil && searchPredicate != nil {
             frc.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.currentTabPredicate!, searchPredicate!])
        } else if self.currentTabPredicate != nil {
            frc.fetchRequest.predicate = self.currentTabPredicate
        } else {
             frc.fetchRequest.predicate = searchPredicate
        }
        
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
}

extension MasterViewController: UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        /**
         * Tab bar items controller :
         * Calls function depending on which tab was clicked
         */
        guard let tabs = self.tabBar.items, tabs.count == 3 else {
            print("Error in getting tab bar items")
            return
        }
        
        switch item {
        case tabs[0]:
            self.displayFavouriteContacts()
        case tabs[1]:
            self.displayAllContacts()
        case tabs[2]:
            self.displayFrequentContacts()
        default:
            print("default: error")
        }
    }
    
    func displayFavouriteContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest to reset some settings, and get favourites only :
         * - no fetchLimitNumber
         * - sorted by first name, then last name
         * - predicate to display favourite contacts only (and search results if applicable)
         */
        guard let frc = self.resultController else {
            return
        }
        // Reset fetch limit number
        frc.fetchRequest.fetchLimit = 0
        
        // Get predicate corresponding to favourite (manage search predicate if existing)
        let scdProvider = SearchCoreDataProvider.sharedInstance
        let favouritePredicate = scdProvider.getFavouritePredicate()
        if self.currentSearchPredicate != nil && favouritePredicate != nil {
            frc.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.currentSearchPredicate!, favouritePredicate!])
        } else {
            frc.fetchRequest.predicate = favouritePredicate
        }
        self.currentTabPredicate = favouritePredicate
        
        // Sort by first name, then by last name
        frc.fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
    
    func displayAllContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest to reset default settings :
         * - no fetchLimitNumber
         * - sorted by first name, then last name
         * - no predicate (except search results if applicable)
         */
        guard let frc = self.resultController else {
            return
        }
        // Reset fetch limit number
        frc.fetchRequest.fetchLimit = 0
        
        // Sort by first name, then by last name
        let scdProvider = SearchCoreDataProvider.sharedInstance
        frc.fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        
        // Reset predicate (or keep search predicate)
        if self.currentSearchPredicate != nil {
            frc.fetchRequest.predicate = self.currentSearchPredicate
        } else {
            frc.fetchRequest.predicate = nil
        }
        self.currentTabPredicate = nil
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
    
    func displayFrequentContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest with :
         * - a fetchLimitNumber
         * - sorted by frequency, then first name, then last name
         * - no predicate (except search results if applicable)
         */
        guard let frc = self.resultController else {
            return
        }
        // Set fetch limit number
        let fetchLimitNumber = 5
        frc.fetchRequest.fetchLimit = fetchLimitNumber
        
        // Sort by frequency, then by first name, then by last name
        let scdProvider = SearchCoreDataProvider.sharedInstance
        frc.fetchRequest.sortDescriptors = scdProvider.getFrequentSortDescriptor()
        
        // Reset predicate (or keep search predicate)
        if self.currentSearchPredicate != nil {
            frc.fetchRequest.predicate = self.currentSearchPredicate
        } else {
            frc.fetchRequest.predicate = nil
        }
        self.currentTabPredicate = nil
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
}

extension MasterViewController: NSFetchedResultsControllerDelegate {
    // BASIC METHOD :
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
    // Could be replaced by following methods :
    /*
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
     }
     
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
     
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
     }
     */
}
