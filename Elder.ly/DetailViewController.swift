//
//  DetailViewController.swift
//  Elder.ly
//
//  Created by Maxime REVEL on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var communicationSegmentedControl: UISegmentedControl!
    
    weak var contact: Contact?
    
    func configureView() {
        // Update the user interface for the detail item.
        self.contactImage.layer.cornerRadius = self.contactImage.frame.size.width / 2;
        
        self.navigationController?.isToolbarHidden = false
        
        let options = UIBarButtonItem(title: "title", style: .plain, target: self, action: #selector(displayOptions))
        
        //change to play
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = options
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Options"
//        var items = [UIBarButtonItem]()
//        items.append( options )
//        self.navigationController?.toolbar.items = items
    }
    
    @objc func displayOptions() {
        // TODO : display options
        print("display options clicked")
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

