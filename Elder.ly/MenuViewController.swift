//
//  MenuViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 01/12/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round user profil image
        self.userImage.image = UIImage(named: "default-avatar")
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.contentMode = .scaleAspectFill
        
        
        // Logout Button style
        self.logoutButton.setTitleColor(UIColor.purpleLight(), for: .normal)
        self.logoutButton.setTitleColor(UIColor.purpleDark(), for: .highlighted)
        self.logoutButton.backgroundColor = .clear
        self.logoutButton.layer.cornerRadius = self.logoutButton.frame.size.height / 2
        self.logoutButton.layer.borderWidth = 1
        self.logoutButton.layer.borderColor = UIColor.purpleLight().cgColor
        
        // Close Button style
        self.closeButton.setTitleColor(UIColor.purpleLight(), for: .normal)
        self.closeButton.setTitleColor(UIColor.purpleDark(), for: .highlighted)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
