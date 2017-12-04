//
//  SignUpViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    @IBOutlet weak var requestIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgottenPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // Buttons Styling
        self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height / 2
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = UIColor.orange().cgColor
        self.signUpButton.layer.cornerRadius = self.signUpButton.frame.size.height / 2
        self.forgottenPasswordButton.layer.borderWidth = 1
        self.forgottenPasswordButton.layer.borderColor = UIColor.orange().cgColor
        self.forgottenPasswordButton.layer.cornerRadius = self.forgottenPasswordButton.frame.size.height / 2
        
        // Setup default phone number
        phoneNumberField.text = UserDefaults.standard.getUserPhoneNumber()
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
    
    @IBAction func signupPressed(_ sender: Any) {
        // Create and push SignUpViewController
        print("SignUp Pressed")
        let signUpViewController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        self.present(signUpViewController, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        loginButton.isEnabled = false
        requestIndicator.isHidden = false
        
        var isInvalidField = false
        
        if !UserValidationUtil.validatePassword(password: self.passwordField.text!) {
            isInvalidField = true
            setHighlightTextField(field: passwordField)
            self.loginButton.isEnabled = true
            self.requestIndicator.isHidden = true
            passwordField.becomeFirstResponder()
        } else {
            resetHighlightTextField(field: passwordField)
        }
        
        if !UserValidationUtil.validatePhone(phone: self.phoneNumberField.text!) {
            isInvalidField = true
            setHighlightTextField(field: phoneNumberField)
            self.loginButton.isEnabled = true
            self.requestIndicator.isHidden = true
            phoneNumberField.becomeFirstResponder()
        } else {
            resetHighlightTextField(field: phoneNumberField)
        }
        
        if !isInvalidField {
            let wsProvider = WebServicesProvider.sharedInstance
            wsProvider.userLogin(phone: self.phoneNumberField.text!, password: self.passwordField.text!, success: {
                UserDefaults.standard.setAuth()
                DispatchQueue.main.async {
                    self.loginButton.isEnabled = true
                    self.requestIndicator.isHidden = true
                }
                self.dismiss(animated: true)
            }) { (error) in
                UserDefaults.standard.unsetAuth()
                DispatchQueue.main.async {
                    self.loginButton.isEnabled = true
                    self.requestIndicator.isHidden = true
                }
                self.alertConnectionError()
            }
            if self.rememberSwitch.isOn {
                UserDefaults.standard.setUserPhoneNumber(phone: self.phoneNumberField.text!)
            }
        }
    }
    
    func setHighlightTextField(field: UITextField) {
        field.layer.borderColor = UIColor.red.cgColor
        field.layer.borderWidth = 1.0
    }
    
    func resetHighlightTextField(field: UITextField) {
        field.layer.borderWidth = 0.0
    }
    
    @IBAction func forgottenPasswordPressed(_ sender: Any) {
        let errorTitle = NSLocalizedString("error", comment: "Error")
        let okString = NSLocalizedString("OK", comment: "OK")
        let forgottenTitle = NSLocalizedString("Forgotten password", comment: "Forgotten password")
        let phoneRequestString = NSLocalizedString("Please enter your phone number", comment: "Please enter your phone number")
        let phoneNumberString = NSLocalizedString("Phone number", comment: "Phone number")
        let sendString = NSLocalizedString("Send", comment: "Send")
        let sentPasswordString = NSLocalizedString("Sent password", comment: "Sent password")
        let noAccountErrorString = NSLocalizedString("No account", comment: "No account")
        let invalidPhoneString = NSLocalizedString("Invalid phone", comment: "Invalid phone")
        
        let alert = UIAlertController(title: forgottenTitle, message: phoneRequestString, preferredStyle: .alert)
        alert.addTextField { (numberField) in
            numberField.placeholder = phoneNumberString
        }
        let alertAction = UIAlertAction(title: sendString, style: UIAlertActionStyle.default) { (_) in
            let resultAlert = UIAlertController(title: forgottenTitle, message: "", preferredStyle: .alert)
            var resultButton: UIAlertAction?
            if let fields = alert.textFields {
                let field = fields[0]
                let number = field.text!
                if (UserValidationUtil.validatePhone(phone: number)) {
                    WebServicesProvider.sharedInstance.forgottenPassword(phone: number, success: {
                        resultAlert.message = sentPasswordString
                        resultButton = UIAlertAction(title: okString, style: .default, handler: nil)
                        resultAlert.addAction(resultButton!)
                        self.present(resultAlert, animated: true)
                    }, failure: { (error) in
                        resultAlert.message = noAccountErrorString
                        resultButton = UIAlertAction(title: okString, style: .cancel, handler: nil)
                        resultAlert.addAction(resultButton!)
                        self.present(resultAlert, animated: true)
                    })
                } else {
                    resultAlert.message = invalidPhoneString
                    resultButton = UIAlertAction(title: okString, style: .destructive) { (_) in
                        self.present(alert, animated: true)
                    }
                    resultAlert.addAction(resultButton!)
                    self.present(resultAlert, animated: true)
                }
            } else {
                resultAlert.message = errorTitle
                resultButton = UIAlertAction(title: okString, style: .destructive, handler: nil)
                resultAlert.addAction(resultButton!)
                self.present(resultAlert, animated: true)
            }
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
    
    func alertConnectionError() {
        let errorTitle = NSLocalizedString("error", comment: "Error")
        let errorConnection = NSLocalizedString("errorConnection", comment: "Erreur de connexion")
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

