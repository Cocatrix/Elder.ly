//
//  MenuViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 01/12/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
	@IBOutlet weak var backgroundView: UIView!
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
		
		
		
		//Adding the blur effet on the view
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = backgroundView.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		backgroundView.addSubview(blurEffectView)
		backgroundView.sendSubview(toBack: blurEffectView)
		
		//Adding motion on Labels
		let xAxisMotionStrong = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		xAxisMotionStrong.maximumRelativeValue = 20
		xAxisMotionStrong.minimumRelativeValue = -20
		userPhoneNumer.addMotionEffect(xAxisMotionStrong)
		userFullName.addMotionEffect(xAxisMotionStrong)
		userEmail.addMotionEffect(xAxisMotionStrong)
		
		let xAxisMotionLightInverted = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		xAxisMotionLightInverted.maximumRelativeValue = -10
		xAxisMotionLightInverted.minimumRelativeValue = 10
		userImage.addMotionEffect(xAxisMotionLightInverted)
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.view.isHidden = true // hinding the view before animations
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		//Animation on the view
		view.layer.transform = CATransform3DMakeTranslation(-view.frame.width, 0, 0)
		self.view.isHidden = false
		UIView.animate(withDuration: 0.22) {
			self.view.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
		}
	}
    
    func updateMenuView() {
        guard let phone = cuPhone, let email = cuEmail, let firstName = cuFirstName, let lastName = cuLastName else {
            return
        }
 
        // Round user profile image
        self.userImage.gravatarImage(email: email)
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.contentMode = .scaleAspectFill
        
        userPhoneNumer.text = phone.toPhoneNumber()
        userEmail.text = email
        userFullName.text = "\(firstName) \(lastName)"
    }
    
	@IBAction func dismissMenu(_ sender: Any) {
		
		//Closing with animation, making sure the user cannot tap twice on the close button
		self.closeButton.isEnabled = false
		UIView.animate(withDuration: 0.22, animations: {
			self.view.layer.transform = CATransform3DMakeTranslation(-self.view.frame.width, 0, 0)
		}) { (_) in
			self.dismiss(animated: false, completion: nil)
		}
		
	}
	@IBAction func onDisconnectPressed(_ sender: Any) {
        let disconnectionAlert = UIAlertController(title: "Disconnection".localized, message: "Are you sure you want to disconnect ?".localized, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            WebServicesProvider.sharedInstance.revokeToken()
            UserDefaults.standard.unsetAuth()
            UserDefaults.standard.setFirstLogin()
            let controller = LoginViewController(nibName: nil, bundle: nil)
            self.present(controller, animated: false, completion: nil)
            self.dismiss(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
            return
        }
        disconnectionAlert.addAction(OKAction)
        disconnectionAlert.addAction(cancelAction)
        self.present(disconnectionAlert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
