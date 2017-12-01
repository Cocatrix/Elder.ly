//
//  DetailViewController.swift
//  Elder.ly
//
//  Created by Maxime REVEL on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var contactFullname: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var communicationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var addFavouriteButton: UIButton!
    
    let addFavouritesString: String = "Add to your favourites"
    let removeFavouritesString: String = "Remove from your favourites"
    
    weak var contact: Contact?
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let contact = self.contact else {
            return
        }
        
        self.contactFullname.text = contact.firstName! + " " + contact.lastName!
        
        self.emailButton.setTitle(contact.email, for: .normal)
        self.callButton.setTitle(contact.phone, for: .normal)
        
        // Change addFavouriteButton label depending on favourite status
        if let isFavourite = self.contact?.isFavouriteUser {
            if isFavourite {
                self.addFavouriteButton.setTitle(self.removeFavouritesString.localized, for: .normal)
            } else {
                self.addFavouriteButton.setTitle(self.addFavouritesString.localized, for: .normal)
            }
        }
        
        //TODO : display real avatar profil
        // Set avatar image
        self.contactImage.image = UIImage(named: "default-avatar")
        self.contactImage.layer.cornerRadius = self.contactImage.frame.size.width / 2
        self.contactImage.contentMode = .scaleAspectFill
        
        // Segment Control Font Size
        let font = UIFont.systemFont(ofSize: 17)
        self.segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                                for: .normal)
        
        let options = UIBarButtonItem(title: "Options".localized, style: .plain, target: self, action: #selector(displayOptions))
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = options
    }
    
    @objc func displayOptions() {
        // TODO : display options
        print("display options clicked")
        
        let actionSheet = UIAlertController.init(title: "Options".localized, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction.init(title: "Edit".localized, style: UIAlertActionStyle.default, handler: { (action) in
            self.editContact()
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Delete".localized, style: UIAlertActionStyle.destructive, handler: { (action) in
            self.deleteContact()
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Cancel".localized, style: UIAlertActionStyle.cancel, handler: { (action) in }))
        
        //Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    @IBAction func interactionPressed(_ segment: UISegmentedControl) {
        
        guard
            let phoneNumber = self.contact?.phone,
            let email = self.contact?.email
            else {
            return
        }
        
        switch segment.selectedSegmentIndex {
        case 0: // Text message
            print("text", phoneNumber)
            CommunicationUtil.text(phoneNumber: phoneNumber)
            break
        case 1: // Call
            print("call", phoneNumber)
            CommunicationUtil.call(phoneNumber: phoneNumber)
            break
        case 2: // eMail
            print("email", email)
            CommunicationUtil.email(emailAdress: email)
            break
        default:
            break
        }
    }
    
    @IBAction func emailPressed(_ sender: Any) {
        guard let email = self.contact?.email else {
            return
        }
        CommunicationUtil.email(emailAdress: email)
    }
    
    @IBAction func phoneNumberPressed(_ sender: Any) {
        guard let phoneNumber = self.contact?.phone else {
            return
        }
        CommunicationUtil.call(phoneNumber: phoneNumber)
    }
    
    func editContact() {
        print("Edit pressed")
    }
    
    func deleteContact() {
        print("Delete pressed")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Contact? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    @IBAction func pressAddFavourite(_ sender: Any) {
        guard let isFavourite = self.contact?.isFavouriteUser else {
            print("Not found whether favourite")
            return
        }
        self.contact!.updateIsFavouriteContact(shouldBeFavourite: !isFavourite, success: {
            print("Contact favourite status updated")
        }) { (error) in
            print("Contact favourite status not updated")
        }
        // Change addFavouriteButton label depending on favourite status
        if !isFavourite {
            self.addFavouriteButton.setTitle(self.removeFavouritesString.localized, for: .normal)
        } else {
            self.addFavouriteButton.setTitle(self.addFavouritesString.localized, for: .normal)
        }
    }
}
