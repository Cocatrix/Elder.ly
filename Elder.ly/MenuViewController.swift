//
//  MenuViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 01/12/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var userPhoneNumer: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var cuPhone: String?
    var cuEmail: String?
    var cuFirstName: String?
    var cuLastName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateMenuView()
      
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
    
    func updateMenuView() {
        // Round user profil image
        guard let phone = cuPhone, let email = cuEmail, let firstName = cuFirstName, let lastName = cuLastName else {
            return
        }
 
        self.userImage.gravatarImage(email: email)
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.contentMode = .scaleAspectFill
        
        userPhoneNumer.text = phone.toPhoneNumber()
        userEmail.text = email
        userFullName.text = "\(firstName) \(lastName)"
    }
    
    @IBAction func onDisconnectPressed(_ sender: Any) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
