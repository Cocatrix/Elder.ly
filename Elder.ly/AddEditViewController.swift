//
//  AddEditViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 28/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileView: UIPickerView!
    
    var selectedProfile: String = ""    
    var profilesList: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
        let profile = self.selectedProfile
        
        if (!UserValidationUtil.validateFirstname(firstname: firstName)) {
            firstNameTextField.layer.borderWidth = 1.0
            firstNameTextField.layer.borderColor = UIColor.red.cgColor
            firstNameTextField.becomeFirstResponder()
        } else if (!UserValidationUtil.validateLastname(lastname: lastName)) {
            firstNameTextField.layer.borderWidth = 0.0
            lastNameTextField.layer.borderWidth = 1.0
            lastNameTextField.layer.borderColor = UIColor.red.cgColor
            lastNameTextField.becomeFirstResponder()
        } else if (!UserValidationUtil.validatePhone(phone: phone)) {
            firstNameTextField.layer.borderWidth = 0.0
            lastNameTextField.layer.borderWidth = 0.0
            phoneNumberTextField.layer.borderWidth = 1.0
            phoneNumberTextField.layer.borderColor = UIColor.red.cgColor
            phoneNumberTextField.becomeFirstResponder()
        } else if (!UserValidationUtil.validateEmail(email: email)) {
            firstNameTextField.layer.borderWidth = 0.0
            lastNameTextField.layer.borderWidth = 0.0
            phoneNumberTextField.layer.borderWidth = 0.0
            emailTextField.layer.borderWidth = 1.0
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailTextField.becomeFirstResponder()
        } else {
            firstNameTextField.layer.borderWidth = 0.0
            lastNameTextField.layer.borderWidth = 0.0
            phoneNumberTextField.layer.borderWidth = 0.0
            emailTextField.layer.borderWidth = 0.0
            WebServicesProvider.sharedInstance.createContactOnServer(email: email, phone: phone, firstName: firstName, lastName: lastName, profile: profile, gravatar: "", isFamilinkUser: false, isEmergencyUser: false, success: {
                print("contact successfully created with profile " + profile)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }, failure: { (error) in
                print("Phone : " + phone + ", Firstname : " + firstName + ", Lastname : " + lastName + ", Email : " + email + ", Profile : " + profile)
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
