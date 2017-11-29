//
//  SignUpViewController.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 27/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneView: UITextField!
    @IBOutlet weak var lastnameView: UITextField!
    @IBOutlet weak var firstnameView: UITextField!
    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var profileView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil) // Do any additional setup after loading the view.
        phoneView.text = "0123456789"
        firstnameView.text = "John"
        lastnameView.text = "Doe"
        emailView.text = "john.doe@nobody.net"
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
        print("SignUp Pressed")
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        print("Register pressed")
        if (validatePhone(phone: phoneView.text!)
            && validateFirstname(firstname: firstnameView.text!)
            && validateLastname(lastname: lastnameView.text!)
            && validateEmail(email: emailView.text!)) {
            let phone = phoneView.text!
            let password = "0000"
            let firstname = firstnameView.text!
            let lastname = lastnameView.text!
            let email = emailView.text!
            let profile = "FAMILLE"
            WebServicesProvider.sharedInstance.createUser(phone: phone, password: password, firstName: firstname, lastName: lastname, email: email, profile: profile, success: {
                print("User created")
                self.dismiss(animated: true, completion: {
                    
                })
            }, failure: { (error) in
                print(error)
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
    
    func validatePhone(phone: String) -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: phone, options: [], range: NSMakeRange(0, phone.count))
            if let res = matches.first {
                let result = res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phone.count
                print("Phone OK")
                return result
            } else {
                print("Phone not OK")
                phoneView.becomeFirstResponder()
                return false
            }
        } catch {
            print(error)
        }
        phoneView.becomeFirstResponder()
        return false;
    }
    
    func validateFirstname(firstname: String) -> Bool {
        let result = firstname.count > 0
        if (result) {
            print("Firstname OK")
        } else {
            print("Firstname not OK")
            firstnameView.becomeFirstResponder()
        }
        return result
    }
    
    func validateLastname(lastname: String) -> Bool {
        let result = lastname.count > 0
        if (result) {
            print("Lastname OK")
        } else {
            print("Lastname not OK")
            lastnameView.becomeFirstResponder()
        }
        return result
    }
    
    func validateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        if (result) {
            print("Email OK")
        } else {
            print("Email not OK")
            emailView.becomeFirstResponder()
        }
        return result
    }
    
    func validateProfile(profile: String) -> Bool {
        return false;
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
