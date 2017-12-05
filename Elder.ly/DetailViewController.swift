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
    @IBOutlet weak var starDetailImage: UIImageView!
    
    let addFavouritesString: String = "Add to your favourites".localized
    let removeFavouritesString: String = "Remove from your favourites".localized
    
    weak var contact: Contact?
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let contact = self.contact else {
            return
        }
        // Display contact fullname
        self.contactFullname.text = contact.firstName! + " " + contact.lastName!
        
        // Email and PhoneNumber buttons tyiyle and style
        self.emailButton.setTitle(contact.email, for: .normal)
        self.emailButton.setTitleColor(UIColor.purple(), for: .normal)
        self.emailButton.setTitleColor(UIColor.purpleDark(), for: .highlighted)
        self.callButton.setTitle(contact.phone, for: .normal)
        self.callButton.setTitleColor(UIColor.purple(), for: .normal)
        self.callButton.setTitleColor(UIColor.purpleDark(), for: .highlighted)
        
        // Favorites styling
        self.addFavouriteButton.layer.borderWidth = 1
        self.addFavouriteButton.layer.borderColor = UIColor.orange().cgColor
        self.addFavouriteButton.layer.cornerRadius = self.addFavouriteButton.frame.size.height / 2
        
        // Change addFavouriteButton label depending on favourite status
        if let isFavourite = self.contact?.isFavouriteUser {
            if isFavourite {
                self.addFavouriteButton.setTitle(self.removeFavouritesString, for: .normal)
                self.starDetailImage.image = UIImage(named: "star-fill.png")
            } else {
                self.addFavouriteButton.setTitle(self.addFavouritesString, for: .normal)
                self.starDetailImage.image = nil
            }
        }
        
        // Set avatar image
        if let email = contact.email {
            self.contactImage.gravatarImage(email: email, size: Gravatar.Size.large)
        } else {
            self.contactImage.image = UIImage(named: "default-avatar")
        }
        self.contactImage.layer.cornerRadius = self.contactImage.frame.size.width / 2
        self.contactImage.contentMode = .scaleAspectFill
        
        // Segment Control Style
        let font = UIFont.systemFont(ofSize: 17)
        self.segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        self.segmentControl.layer.cornerRadius = self.segmentControl.frame.size.height / 2
        self.segmentControl.layer.borderColor = UIColor.purple().cgColor
        self.segmentControl.layer.borderWidth = 1
        self.segmentControl.tintColor = UIColor.purple()
        //self.segmentControl.backgroundColor = UIColor.purple()
        self.segmentControl.layer.masksToBounds = true
        
        let options = UIBarButtonItem(title: "Options".localized, style: .plain, target: self, action: #selector(displayOptions))
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = options
        
        //Adding motion on Labels
        let xAxisMotionStrong = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xAxisMotionStrong.maximumRelativeValue = 20
        xAxisMotionStrong.minimumRelativeValue = -20
        self.contactFullname.addMotionEffect(xAxisMotionStrong)
        
        let xAxisMotionLightInverted = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xAxisMotionLightInverted.maximumRelativeValue = -10
        xAxisMotionLightInverted.minimumRelativeValue = 10
        self.contactImage.addMotionEffect(xAxisMotionLightInverted)
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
        case 0:
            CommunicationUtil.text(phoneNumber: phoneNumber, contact: self.contact!)
            break
        case 1:
            CommunicationUtil.call(phoneNumber: phoneNumber, contact: self.contact!)
            break
        case 2:
            CommunicationUtil.email(emailAdress: email, contact: self.contact!)
            break
        default:
            break
        }
    }
    
    @IBAction func emailPressed(_ sender: Any) {
        guard let email = self.contact?.email else {
            return
        }
        CommunicationUtil.email(emailAdress: email, contact: self.contact!)
    }
    
    @IBAction func phoneNumberPressed(_ sender: Any) {
        guard let phoneNumber = self.contact?.phone else {
            return
        }
        CommunicationUtil.call(phoneNumber: phoneNumber, contact: self.contact!)
    }
    
    func editContact() {
        guard let contactToEdit = self.contact else {
            print("No contact in DetailView")
            return
        }
        let controller = AddEditViewController(nibName: nil, bundle: nil)
        controller.contact = contactToEdit
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func deleteContact() {
        let deleteAlertController = AlertDialogProvider.deleteAlertController()
        let OKAction = UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
            guard let id = self.contact?.wsId else {
                return
            }
            WebServicesProvider.sharedInstance.deleteContactOnServer(wsId: id, success: {
                print("delete success")
                DispatchQueue.main.async {
                    self.splitViewController?.popToMasterViewController()
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
        deleteAlertController.addAction(OKAction)
        self.present(deleteAlertController, animated: true) {
        }
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
            let starFill = UIImage(named: "star-fill.png")
            
            DispatchQueue.main.async {
                // Change addFavouriteButton label depending on favourite status
                if !isFavourite {
                    print("Contact added to favourites")
                    self.addFavouriteButton.setTitle(self.removeFavouritesString, for: .normal)
                    self.starDetailImage.image = starFill
                } else {
                    print("Contact removed from favourites")
                    self.addFavouriteButton.setTitle(self.addFavouritesString, for: .normal)
                    self.starDetailImage.image = nil
                }   
            }
        }) { (error) in
            print("Contact favourite status not updated")
        }
    }
}
