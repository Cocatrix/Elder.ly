//
//  ContactTableViewCell.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 29/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
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
    
    @IBAction func callPressed(_ sender: Any) {
        // TODO : call link the real contact phoneNumber
        CommunicationUtil.call(phoneNumber: "0123456789")
    }
}

