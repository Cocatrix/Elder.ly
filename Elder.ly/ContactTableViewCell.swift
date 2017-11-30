//
//  ContactTableViewCell.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 29/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    var phoneNumber: String?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.image = UIImage(named: "default-avatar");
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
        self.avatarImageView.contentMode = .scaleAspectFill
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setPhoneNumber(phone: String) {
        self.phoneNumber = phone
    }
    
    @IBAction func callPressed(_ sender: Any) {
        guard let phone = self.phoneNumber else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: "tel://\(phone)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "tel://\(phone)")!)
        }
    }
}

