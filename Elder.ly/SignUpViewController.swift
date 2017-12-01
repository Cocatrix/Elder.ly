//
//  SignUpViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneView: UITextField!
    @IBOutlet weak var lastnameView: UITextField!
    @IBOutlet weak var firstnameView: UITextField!
    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
    @IBOutlet weak var profileView: UIPickerView!
    var selectedProfile: String = ""
    
    var profilesList: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil) // Do any additional setup after loading the view.
        
        let preferencesProfiles = UserDefaults.standard.value(forKey: "elderlyProfiles")
        if ((preferencesProfiles) != nil) {
            print("Preferences set")
            self.profilesList = preferencesProfiles as? [String] ?? ["ERROR"]
            self.selectedProfile = profilesList[0]
        } else {
            print("Preferences empty")
            self.profilesList = []
            self.selectedProfile = ""
        }
        profileView.dataSource = self
        profileView.delegate = self
        
        loadProfilesFromWS()
        
//        phoneView.text = "0123456789"
//        firstnameView.text = "John"
//        lastnameView.text = "Doe"
//        emailView.text = "john.doe@nobody.net"
//        passwordView.text = "0000"
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
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        // Create and push LoginViewController
        print("Login Pressed")
        self.dismiss(animated: true)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        print("Register pressed")
        let phone = phoneView.text!
        let password = passwordView.text!
        let firstname = firstnameView.text!
        let lastname = lastnameView.text!
        let email = emailView.text!
        let profile = selectedProfile
        if (!UserValidationUtil.validatePhone(phone: phone)) {
            phoneView.layer.borderWidth = 1.0
            phoneView.layer.borderColor = UIColor.red.cgColor
            phoneView.becomeFirstResponder()
        } else if (!UserValidationUtil.validateFirstname(firstname: firstname)) {
            phoneView.layer.borderWidth = 0.0
            firstnameView.layer.borderWidth = 1.0
            firstnameView.layer.borderColor = UIColor.red.cgColor
            firstnameView.becomeFirstResponder()
        } else if (!UserValidationUtil.validateLastname(lastname: lastname)) {
            phoneView.layer.borderWidth = 0.0
            firstnameView.layer.borderWidth = 0.0
            lastnameView.layer.borderWidth = 1.0
            lastnameView.layer.borderColor = UIColor.red.cgColor
            lastnameView.becomeFirstResponder()
        } else if (!UserValidationUtil.validateEmail(email: email)) {
            phoneView.layer.borderWidth = 0.0
            firstnameView.layer.borderWidth = 0.0
            lastnameView.layer.borderWidth = 0.0
            emailView.layer.borderWidth = 1.0
            emailView.layer.borderColor = UIColor.red.cgColor
            emailView.becomeFirstResponder()
        } else if (!UserValidationUtil.validatePassword(password: password)) {
            phoneView.layer.borderWidth = 0.0
            firstnameView.layer.borderWidth = 0.0
            lastnameView.layer.borderWidth = 0.0
            emailView.layer.borderWidth = 0.0
            passwordView.layer.borderWidth = 1.0
            passwordView.layer.borderColor = UIColor.red.cgColor
            passwordView.becomeFirstResponder()
        } else {
            phoneView.layer.borderWidth = 0.0
            firstnameView.layer.borderWidth = 0.0
            lastnameView.layer.borderWidth = 0.0
            emailView.layer.borderWidth = 0.0
            passwordView.layer.borderWidth = 0.0
            WebServicesProvider.sharedInstance.createUser(phone: phone, password: password, firstName: firstname, lastName: lastname, email: email, profile: profile, success: {
                print("User created")
                self.dismiss(animated: true, completion: {
                    
                })
            }, failure: { (error) in
                print(error ?? "ERROR")
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                    self.alertErrorSignup(message: (error?.localizedDescription)!)
                }
                print("Phone : " + phone + ", Password : " + password + ", Firstname : " + firstname + ", Lastname : " + lastname + ", Email : " + email + ", Profile : " + profile)
            })
        }
    }
    
    func alertErrorSignup(message: String) {
        let alert = UIAlertController(title: "User not created", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Click", style: UIAlertActionStyle.default)
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return profilesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profilesList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedProfile = profilesList[row]
    }
    
    func loadProfilesFromWS() {
        WebServicesProvider.sharedInstance.getProfiles(success: { (profiles) in
            DispatchQueue.main.async {
                self.profilesList = profiles
                self.selectedProfile = self.profilesList[0]
                self.profileView.reloadAllComponents()
            }
            print("Setting preferences")
            UserDefaults.standard.set(profiles, forKey: "elderlyProfiles")
        }) { (error) in
            print(error ?? "Error")
        }
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
