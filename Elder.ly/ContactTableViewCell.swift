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
    var contact: Contact?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var starFavoriteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Avatar round
        self.avatarImageView.image = UIImage(named: "default-avatar")
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.contentMode = .scaleAspectFill
        
        // Name Label Style
        self.nameLabel.textColor = UIColor.purple()
        
        // Call Button style
        self.callButton.setTitleColor(UIColor.orange(), for: .normal)
        self.callButton.backgroundColor = .clear
        self.callButton.layer.cornerRadius = self.callButton.frame.size.height / 2
        self.callButton.layer.borderWidth = 1
        self.callButton.layer.borderColor = UIColor.orange().cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setPhoneNumber(phone: String) {
        self.phoneNumber = phone
    }
    
    func setContact(contact: Contact) {
        self.contact = contact
    }
    
    @IBAction func callPressed(_ sender: Any) {
        guard let phone = self.phoneNumber, let contact = self.contact else {
            return
        }
        CommunicationUtil.call(phoneNumber: phone, contact: contact)
    }
}

