//
//  Register1ViewController.swift
//  CoffeeMap
//
//  Created by Phan Tiến Anh on 8/19/20.
//  Copyright © 2020 Phan Tiến Anh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var lblPass: UILabel!
    @IBOutlet weak var lblConfirm: UILabel!
    @IBOutlet weak var lblSignin: UILabel!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtConfirm: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPass.isSecureTextEntry = true
        txtConfirm.isSecureTextEntry = true
        txtPass.delegate = self
        txtMail.delegate = self
        txtConfirm.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func signup() {
        if txtPass.text != txtConfirm.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: txtMail.text!, password: txtPass.text!){ (user, error) in
                if error == nil {
                    let alertController = UIAlertController(title: "Success", message: "Your account is already to login", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func signInClick() {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            if textField == txtMail {
                txtMail.resignFirstResponder()
                txtPass.becomeFirstResponder()
            } else if (textField == txtPass) {
                txtPass.resignFirstResponder()
                txtConfirm.becomeFirstResponder()
            } else {
                txtConfirm.resignFirstResponder()
            }
            
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtMail {
            textField.returnKeyType = .next
        } else if (textField == txtPass) {
            textField.returnKeyType = .next
        } else {
            textField.returnKeyType = .done
        }
        
        return true
    }
    
}
