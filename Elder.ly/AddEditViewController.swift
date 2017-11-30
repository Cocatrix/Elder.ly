//
//  AddEditViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 28/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func onButtonAddClick(_ sender: Any) {
        print("adding contact")
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let phone = phoneNumberTextField.text!
        let email = emailTextField.text!
        if (!UserValidationUtil.validatePhone(phone: phone)) {
            phoneNumberTextField.becomeFirstResponder()
        } else if (!UserValidationUtil.validateFirstname(firstname: firstName)) {
            firstNameTextField.becomeFirstResponder()
        } else if (!UserValidationUtil.validateLastname(lastname: lastName)) {
            lastNameTextField.becomeFirstResponder()
        } else if (!UserValidationUtil.validateEmail(email: email)) {
            emailTextField.becomeFirstResponder()
        } else {
            WebServicesProvider.sharedInstance.createContactOnServer(email: email, phone: phone, firstName: firstName, lastName: lastName, profile: "FAMILLE", gravatar: "", isFamilinkUser: false, isEmergencyUser: false, success: {
                print("contact successfully created")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }                
            }, failure: { (error) in
                let myError = error as NSError?
                if myError?.code == 401 {
                    UserDefaults.standard.unsetAuth()
                    let controller = LoginViewController(nibName: nil, bundle: nil)
                    self.present(controller, animated: false, completion: nil)
                } else {
                    self.alertUnknownError()
                }
            })
        }
    }
    
    func alertUnknownError() {
        let errorTitle = NSLocalizedString("error", comment: "Error")
        let errorConnection = NSLocalizedString("error", comment: "Erreur Inconnue")
        let okString = NSLocalizedString("OK", comment: "OK")
        
        let errorAlertController = UIAlertController(title: errorTitle, message: errorConnection, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: okString, style: .default)
        errorAlertController.addAction(OKAction)
        self.present(errorAlertController, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
