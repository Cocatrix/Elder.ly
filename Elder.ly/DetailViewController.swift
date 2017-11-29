//
//  DetailViewController.swift
//  Elder.ly
//
//  Created by Maxime REVEL on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var contactImage: UIImageView!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let contact = detailItem {
            if let label = detailDescriptionLabel {
                label.text = contact.firstName
            }
        }
        
        self.contactImage.layer.cornerRadius = self.contactImage.frame.size.width / 2;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
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

