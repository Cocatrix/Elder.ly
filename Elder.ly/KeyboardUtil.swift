//
//  KeyboardUtil.swift
//  Elder.ly
//
//  Created by Nicolas Vergoz on 29/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
