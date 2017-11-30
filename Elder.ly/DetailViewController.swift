//
//  DetailViewController.swift
//  Elder.ly
//
//  Created by Maxime REVEL on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var communicationSegmentedControl: UISegmentedControl!
    
    weak var contact: Contact?
    
    func configureView() {
        // Update the user interface for the detail item.
        self.contactImage.layer.cornerRadius = self.contactImage.frame.size.width / 2;
        
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
        switch segment.selectedSegmentIndex {
        case 0: // Text message
            // TODO : insert the real contact phone number
            CommunicationUtil.text(phoneNumber: "0123456789")
            break
        case 1: // Call
            // TODO : insert the real contact phone number
            CommunicationUtil.call(phoneNumber: "0123456789")
            break
        case 2: // eMail
            CommunicationUtil.email(emailAdress: "email@emai.com")
            break
        default:
            break
        }
    }
    
    @IBAction func emailPressed(_ sender: Any) {
        CommunicationUtil.email(emailAdress: "email@email.com")
    }
    
    @IBAction func phoneNumberPressed(_ sender: Any) {
        CommunicationUtil.call(phoneNumber: "0123456789")
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


}

