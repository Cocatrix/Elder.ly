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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userImage.image = UIImage(named: "default-avatar")
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.contentMode = .scaleAspectFill
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
