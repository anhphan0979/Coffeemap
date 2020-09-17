//
//  CPasswordViewController.swift
//  CoffeeMap
//
//  Created by Phan Tiến Anh on 8/27/20.
//  Copyright © 2020 Phan Tiến Anh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CPasswordViewController: UIViewController {
    
    @IBOutlet weak var lblCurent: UILabel!
    @IBOutlet weak var lblNew: UILabel!
    @IBOutlet weak var lblConfirm: UILabel!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtCurrentPass: UITextField!
    @IBOutlet weak var txtNewPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtCurrentPass.isSecureTextEntry = true
        txtNewPass.isSecureTextEntry = true        
        txtMail.delegate = self
        txtCurrentPass.delegate = self
        txtNewPass.delegate = self
    }
        
    func changePassword(email: String, currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                completion(error)
            }
            else {
                Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                    completion(error)
                })
            }
        })
    }
    
    @IBAction func ChangePassword() {
        
        self.changePassword(email: txtMail.text!, currentPassword: txtCurrentPass.text!, newPassword: txtNewPass.text!) { (error) in
            if error == nil {
                let alert = UIAlertController(title: "Success", message: "Your password was changed", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion:nil )
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension CPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty == true{
            if textField == txtMail {
                txtMail.resignFirstResponder()
                txtCurrentPass.becomeFirstResponder()
            } else if (textField == txtCurrentPass) {
                txtCurrentPass.resignFirstResponder()
                txtNewPass.becomeFirstResponder()
            } else {
                txtNewPass.resignFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtMail {
            textField.returnKeyType = .continue
        } else if (textField == txtCurrentPass) {
            textField.returnKeyType = .continue
        } else {
            textField.returnKeyType = .done
        }
    }
}
