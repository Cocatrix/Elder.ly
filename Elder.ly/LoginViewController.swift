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
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
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
                UserDefaults.standard.unsetFirstLogin()
                DispatchQueue.main.async {
                    UserDefaults.standard.setLoggedPhoneNumber(phone: self.phoneNumberField.text!)
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
        let errorTitle = "Error".localized
        let okString = "OK".localized
        let forgottenTitle = "Forgotten password".localized
        let phoneRequestString = "Please enter your phone number".localized
        let phoneNumberString = "Phone number".localized
        let sendString = "Send".localized
        let sentPasswordString = "Password sent".localized
        let noAccountErrorString = "No account or distant server communication error".localized
        let invalidPhoneString = "Invalid phone".localized
        
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
        let errorTitle = "Error".localized
        let errorConnection = "Connection error".localized
        let okString = "OK".localized
        
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

