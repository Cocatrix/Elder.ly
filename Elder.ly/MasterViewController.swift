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
    var currentUserPhone: String?
    var currentUserFirstName: String?
    var currentUserLastName: String?
    var currentUserEmail: String?
    
    let searchPlaceholder: String = "Search (by name, email...)".localized
    let myProfileString: String = "My Profile".localized
    let addContactString: String = "Add".localized
    let noContactString: String = "Add your first contact here".localized
    let noFavouriteString: String = "No favourite".localized
    let noFrequentString: String = "No frequent".localized
    let addFavouriteString: String = "Add to your favourites".localized
    
    @IBOutlet weak var emptyTableView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var tutoNewContactImage: UIImageView!
    @IBOutlet weak var tutoNewContactLabel: UILabel!
    @IBOutlet weak var noFavouriteLabel: UILabel!
    @IBOutlet weak var tutoAddFavouriteLabel: UILabel!
    @IBOutlet weak var tutoAddFavouriteImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.tabBar.delegate = self
        

        // NavigationBar colors
        self.navigationController?.navigationBar.tintColor = UIColor.white()
        self.navigationController?.navigationBar.barTintColor = UIColor.purple()
        self.navigationController?.navigationBar.backgroundColor = UIColor.purple()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white()]
        
        // NavigationBar items
        let menuButton = UIBarButtonItem(title: myProfileString, style: .plain, target: self, action: #selector(openMenu(_:)))
        navigationItem.leftBarButtonItem = menuButton
        
        let addButton = UIBarButtonItem(title: addContactString, style: .plain, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // SearchBar colors
        self.searchBar.barTintColor = UIColor.purple()
        let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.textColor = UIColor.white()
        searchTextField?.backgroundColor = UIColor.white10()
        
        // Empty Table View
        self.tutoNewContactLabel.text = self.noContactString
        self.noFavouriteLabel.text = self.noFavouriteString
        self.tutoAddFavouriteLabel.text = self.addFavouriteString
        self.tutoAddFavouriteLabel.textColor = UIColor.orange()
        
        //TabBar
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = UIColor.purple()
        self.tabBar.barTintColor = UIColor.purple()
        self.tabBar.tintColor = UIColor.purpleLight()
        
        self.tabBar.tintColor = UIColor.orange()
        
        displayAllContacts()
        
        // Select Contacts tab at launch
        guard let items = self.tabBar.items, items.count == 3 else {
            return
        }
        self.tabBar.selectedItem = items[1]
        
        self.manageKeyboardDisplaying()
        
        self.searchBar.placeholder = self.searchPlaceholder
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO - clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        // It is related to selected element. Should it still be selected on viewWillAppear ? I think it's not important to comment it for now.
        super.viewWillAppear(animated)
        //self.tutoCheck()
        
        // Setup background image
        let backgroundImage = UIImage(named: "elderly")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.15
        tableView.backgroundColor = .white
        
        // Check Auth
        if !UserDefaults.standard.isAuth() && UserDefaults.standard.isFirstLogin() {
            let controller = LoginViewController(nibName: nil, bundle: nil)
            self.present(controller, animated: false, completion: nil)
        } else {
            // Use WebService to identify and load data
            let wsProvider = WebServicesProvider.sharedInstance
            
            wsProvider.getCurrentUser(success: { (currentUser) in
                self.currentUserEmail = currentUser.email
                self.currentUserPhone = currentUser.phone
                self.currentUserFirstName = currentUser.firstName
                self.currentUserLastName = currentUser.lastName
                DispatchQueue.main.async {
                    self.tutoCheck()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    let context = self.appDelegate().persistentContainer.viewContext
                    let fetchRequest = NSFetchRequest<User>(entityName: "User")
                    let users = try! context.fetch(fetchRequest)
                    let myUser: User
                    if let user = users.first {
                        myUser = user
                        self.currentUserEmail = myUser.email
                        self.currentUserPhone = myUser.phone
                        self.currentUserFirstName = myUser.firstName
                        self.currentUserLastName = myUser.lastName
                    }
                }
                let myError = error as NSError?
                if myError?.code == 401 || myError?.code == WebServicesProvider.AUTH_ERROR {
                    DispatchQueue.main.async {
                        self.present(AlertDialogProvider.authError(), animated: true)
                    }
                } else {
                    print(myError ?? "Error")
                }
            }
            
            wsProvider.getContacts(success: {
                print("Load data : success")
                DispatchQueue.main.async {
                    self.tutoCheck()
                }
            }, failure: { (error) in
                let myError = error as NSError?
                if myError?.code == 401 || myError?.code == WebServicesProvider.AUTH_ERROR {
                    DispatchQueue.main.async {
                        self.present(AlertDialogProvider.authError(), animated: true)
                    }
                } else {
                    print(myError ?? "Error")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func openMenu(_ sender: Any) {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let controller = AddEditViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(controller, animated: false)
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = resultController?.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.contact = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
        if segue.identifier == "openMenu" {
            print("openMenu")
            if let destinationViewController = segue.destination as? MenuViewController {
                destinationViewController.transitioningDelegate = self as? UIViewControllerTransitioningDelegate
                guard let cuPhone = currentUserPhone, let cuEmail = currentUserEmail, let cuFirstName = currentUserFirstName, let cuLastName = currentUserLastName else {
                    return
                }
                destinationViewController.cuPhone = cuPhone
                destinationViewController.cuEmail = cuEmail
                destinationViewController.cuFirstName = cuFirstName
                destinationViewController.cuLastName = cuLastName
                print("updated view")
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.resultController!.sections![section].name
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
        //        if (indexPath.row+1)%2 == 0 {
        //            cell.contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        //        } else {
        //            cell.contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        //        }
        configureCell(cell, withContact: contact!)
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
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
            let deleteAlertController = AlertDialogProvider.deleteAlertController()
            let OKAction = UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
                guard let id = self.resultController?.object(at: indexPath).wsId else {
                    return
                }
                WebServicesProvider.sharedInstance.deleteContactOnServer(wsId: id, success: {
                    print("delete success")
                }, failure: { (error) in
                    let myError = error as NSError?
                    if myError?.code == 401 || myError?.code == WebServicesProvider.AUTH_ERROR {
                        DispatchQueue.main.async {
                            self.present(AlertDialogProvider.authError(), animated: true)
                        }
                    } else {
                        print(myError ?? "Error")
                    }
                })
            }
            deleteAlertController.addAction(OKAction)
            self.present(deleteAlertController, animated: true) {
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
            
            contactCell.setContact(contact: contact)
        
            contactCell.avatarImageView.image = UIImage(named: "default-avatar")
            if let email = contact.email  {
                contactCell.avatarImageView.gravatarImage(email: email)
            }
            
            if contact.isFavouriteUser {
                //UIImage(named: "star-fill.png")
                contactCell.starFavoriteImage.image = UIImage(named: "star-fill.png")
            } else {
                contactCell.starFavoriteImage.image = nil
            } 
        }
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // MARK: - Keyboard
    
    func manageKeyboardDisplaying() {
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        tableView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInset
    }
    
    func tutoCheck() {
        print("tuto check")
        if (self.searchBar.text != "") {
            self.emptyTableView.isHidden = true
            return
        }
        
        if self.resultController?.fetchedObjects?.isEmpty ?? true {
            guard let tabs = self.tabBar.items, tabs.count == 3, let item = self.tabBar.selectedItem else {
                print("Error in getting tab bar items or no selected item")
                return
            }
            self.emptyTableView.isHidden = false
            
            switch item {
            case tabs[0]: // Favourites
                self.tutoNewContactImage.isHidden = true
                self.tutoNewContactLabel.isHidden = true
                self.noFavouriteLabel.isHidden = false
                self.noFavouriteLabel.text = self.noFavouriteString
                self.tutoAddFavouriteLabel.isHidden = false
                self.tutoAddFavouriteImage.isHidden = false
            case tabs[1]: // All contacts
                self.tutoNewContactImage.isHidden = false
                self.tutoNewContactLabel.isHidden = false
                self.noFavouriteLabel.isHidden = true
                self.tutoAddFavouriteLabel.isHidden = true
                self.tutoAddFavouriteImage.isHidden = true
            case tabs[2]: // Frequents
                self.tutoNewContactImage.isHidden = true
                self.tutoNewContactLabel.isHidden = true
                self.noFavouriteLabel.isHidden = false
                self.noFavouriteLabel.text = self.noFrequentString
                self.tutoAddFavouriteLabel.isHidden = true
                self.tutoAddFavouriteImage.isHidden = true
            default:
                print("default: error")
            }
        } else {
            self.emptyTableView.isHidden = true
        }
    }
}

// MARK: - Search Bar

extension MasterViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /**
         * Refresh displayed cells when text has changed. Is also called when field search is emptied.
         * Predicate used for search works with tab predicates (favourites only, most frequent first)
         */
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(searchBar.text == "") { // Same behaviour as cancel button, exit searching
            self.searchBarCancelButtonClicked(searchBar)
        } else {
            self.searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchBar(searchBar, textDidChange: "")
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.tutoCheck()
    }
}

// MARK: - Tab Bar

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
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let scdProvider = SearchCoreDataProvider.sharedInstance
        fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: self.appDelegate().persistentContainer.viewContext,
                                                           sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        // Reset fetch limit number
        frc.fetchRequest.fetchLimit = 0
        
        // Get predicate corresponding to favourite (manage search predicate if existing)
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
        self.resultController = frc
        self.tableView.reloadData()
        tutoCheck()
    }
    
    func displayAllContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest to reset default settings :
         * - no fetchLimitNumber
         * - sorted by first name, then last name
         * - no predicate (except search results if applicable)
         */
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        // Sort by first name, then by last name
        let scdProvider = SearchCoreDataProvider.sharedInstance
        
        fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: self.appDelegate().persistentContainer.viewContext,
                                             sectionNameKeyPath: "firstLetter", cacheName: nil)
        frc.delegate = self
        // Reset fetch limit number
        frc.fetchRequest.fetchLimit = 0
        
        // Sort by first name, then by last name
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
        self.resultController = frc
        self.tableView.reloadData()
        tutoCheck()
    }
    
    func displayFrequentContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest with :
         * - a fetchLimitNumber (5)
         * - sorted by frequency, then first name, then last name
         * - no predicate (except search results if applicable)
         */
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let scdProvider = SearchCoreDataProvider.sharedInstance
        fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: self.appDelegate().persistentContainer.viewContext,
                                                           sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        // Set fetch limit number
        let fetchLimitNumber = 5
        frc.fetchRequest.fetchLimit = fetchLimitNumber
        
        // Sort by frequency, then by first name, then by last name
        frc.fetchRequest.sortDescriptors = scdProvider.getFrequentSortDescriptor()
        
        // Get predicate corresponding to frequency (manage search predicate if existing)
        let frequentPredicate = scdProvider.getFrequentPredicate()
        if self.currentSearchPredicate != nil && frequentPredicate != nil {
            frc.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.currentSearchPredicate!, frequentPredicate!])
        } else {
            frc.fetchRequest.predicate = frequentPredicate
        }
        self.currentTabPredicate = frequentPredicate
        
        
        // Perform fetch and reload data
        try? frc.performFetch()
        self.resultController = frc
        
        self.tableView.reloadData()
        
        tutoCheck()
    }
}

// MARK: - FetchedResultsController

extension MasterViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
        tutoCheck()
    }
}

