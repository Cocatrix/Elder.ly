//
//  AlertDialogProvider.swift
//  Elder.ly
//
//  Created by Arnaud on 04/12/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

class AlertDialogProvider {
    static func authError() -> UIAlertController {
        UserDefaults.standard.unsetAuth()
        let authAlert = UIAlertController(title: "Error".localized, message: "Authentification error".localized, preferredStyle: .alert)
        authAlert.addTextField { (passwordField) in
            passwordField.placeholder = "Password".localized
            passwordField.isSecureTextEntry = true
        }
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let fields = authAlert.textFields else {
                return
            }
            let field = fields[0]
            let password = field.text!
            WebServicesProvider.sharedInstance.userLogin(phone: UserDefaults.standard.getLoggedPhoneNumber(), password: password, success: {
                UserDefaults.standard.setAuth()
            }) { (error) in
                print(error ?? "error")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
            
        })
        authAlert.addAction(OKAction)
        authAlert.addAction(cancelAction)
        return authAlert
    }
    
    static func deleteAlertController() -> UIAlertController {
        let deleteAlertController = UIAlertController(title: "Deleting".localized,
                                                      message: "Are you sure ?".localized,
                                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
            return
        }
        deleteAlertController.addAction(cancelAction)
        return deleteAlertController
    }
}
