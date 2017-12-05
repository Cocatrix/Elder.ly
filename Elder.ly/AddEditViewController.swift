//
//  AddEditViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 28/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileView: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addEditLabel: UILabel!
    
    var selectedProfile: String = ""    
    var profilesList: [String] = [String]()
    var contact: Contact?
    
    @IBOutlet weak var requestIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addContactButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Buttons Styling
        self.addButton.layer.cornerRadius = self.addButton.frame.size.height / 2
        self.addButton.setTitle("Valider".localized, for: .normal)
        
        // Fill picker
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
        
        firstNameTextField.delegate = self
        firstNameTextField.tag = 0
        lastNameTextField.delegate = self
        lastNameTextField.tag = 1
        phoneNumberTextField.delegate = self
        phoneNumberTextField.tag = 2
        emailTextField.delegate = self
        emailTextField.tag = 3
        
        loadProfilesFromWS()
        
        if let contactToEdit = contact {
            
            self.addEditLabel.text = "Edit a contact".localized
            // Fill fields with contact info
            firstNameTextField.text! = contactToEdit.firstName!
            lastNameTextField.text! = contactToEdit.lastName!
            phoneNumberTextField.text! = contactToEdit.phone!
            emailTextField.text! = contactToEdit.email!
            guard let profileToPick = profilesList.index(of: contactToEdit.profile!) else {
                print("Profile not found")
                return
            }
            self.selectedProfile = contactToEdit.profile!
            profileView.selectRow(profileToPick, inComponent: 0, animated: false)
        } else {
            self.addEditLabel.text = "Add a contact".localized
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
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
    
    @IBAction func onButtonAddClick(_ sender: Any) {
        print("Adding or updating contact")
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let phone = phoneNumberTextField.text!
        let email = emailTextField.text!
        let profile = self.selectedProfile
        
        self.addContactButton.isEnabled = false
        self.requestIndicator.isHidden = false
        
        var isInvalidField = false
        
        if (!UserValidationUtil.validateEmail(email: email)) {
            isInvalidField = true
            setHighlightTextField(field: emailTextField)
            self.addContactButton.isEnabled = true
            self.requestIndicator.isHidden = true
            emailTextField.becomeFirstResponder()
        } else {
            resetHighlightTextField(field: emailTextField)
        }
        
        if (!UserValidationUtil.validatePhone(phone: phone)) {
            isInvalidField = true
            setHighlightTextField(field: phoneNumberTextField)
            self.addContactButton.isEnabled = true
            self.requestIndicator.isHidden = true
            phoneNumberTextField.becomeFirstResponder()
        } else {
            resetHighlightTextField(field: phoneNumberTextField)
        }
        
        if (!UserValidationUtil.validateLastname(lastname: lastName)) {
            isInvalidField = true
            setHighlightTextField(field: lastNameTextField)
            self.addContactButton.isEnabled = true
            self.requestIndicator.isHidden = true
            lastNameTextField.becomeFirstResponder()
        } else {
            resetHighlightTextField(field: lastNameTextField)
        }
        
        if (!UserValidationUtil.validateFirstname(firstname: firstName)) {
            isInvalidField = true
            setHighlightTextField(field: firstNameTextField)
            self.addContactButton.isEnabled = true
            self.requestIndicator.isHidden = true
            firstNameTextField.becomeFirstResponder()
        } else {
            resetHighlightTextField(field: firstNameTextField)
        }
        
        if (!isInvalidField) {
            if (self.contact == nil) { // Create contact on server
                WebServicesProvider.sharedInstance.createContactOnServer(email: email, phone: phone, firstName: firstName, lastName: lastName, profile: profile, gravatar: "", isFamilinkUser: false, isEmergencyUser: false, success: {
                    print("contact successfully created with profile " + profile)
                    DispatchQueue.main.async {
                        self.addContactButton.isEnabled = true
                        self.requestIndicator.isHidden = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }, failure: { (error) in
                    print("Phone : " + phone + ", Firstname : " + firstName + ", Lastname : " + lastName + ", Email : " + email + ", Profile : " + profile)
                    let myError = error as NSError?
                    if myError?.code == 401 || myError?.code == WebServicesProvider.AUTH_ERROR {
                        DispatchQueue.main.async {
                            self.addContactButton.isEnabled = true
                            self.requestIndicator.isHidden = true
                            self.present(AlertDialogProvider.authError(), animated: true)
                        }
                    } else {
                        self.alertUnknownError()
                    }
                })
            } else {  // Updating contact on server
                WebServicesProvider.sharedInstance.updateContactOnServer(wsId: contact!.wsId!, email: email, phone: phone, firstName: firstName, lastName: lastName, profile: profile,  gravatar: contact!.gravatar!, isFamilinkUser: false, isEmergencyUser: false, success: {
                        print("contact successfully updated with profile " + profile)
                        // Update Contact to be sent to detailVC
                        self.contact?.firstName = firstName
                        self.contact?.lastName = lastName
                        self.contact?.phone = phone
                        self.contact?.email = email
                        self.contact?.profile = profile
                        DispatchQueue.main.async {
                            self.addContactButton.isEnabled = true
                            self.requestIndicator.isHidden = true
                            guard let viewControllers = self.navigationController?.viewControllers, let detailVC = viewControllers[viewControllers.count - 2] as? DetailViewController else {
                                return
                            }
                            detailVC.contact = self.contact!
                            detailVC.configureView()
                            self.navigationController?.popViewController(animated: true)
                        }
                }, failure: { (error) in
                    print("Phone : " + phone + ", Firstname : " + firstName + ", Lastname : " + lastName + ", Email : " + email + ", Profile : " + profile)
                    let myError = error as NSError?
                    if myError?.code == 401 || myError?.code == WebServicesProvider.AUTH_ERROR {
                        DispatchQueue.main.async {
                            self.addContactButton.isEnabled = true
                            self.requestIndicator.isHidden = true
                            self.present(AlertDialogProvider.authError(), animated: true)
                        }
                    } else {
                        self.alertUnknownError()
                    }
                })
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
    
    func alertUnknownError() {
        let errorTitle = "Error".localized
        let unknownError = "Unknown error".localized
        let okString = "OK".localized
        
        let errorAlertController = UIAlertController(title: errorTitle, message: unknownError, preferredStyle: .alert)
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
