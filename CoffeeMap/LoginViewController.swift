//
//  LoginViewController.swift
//  CoffeeMap
//
//  Created by Phan Tiến Anh on 8/19/20.
//  Copyright © 2020 Phan Tiến Anh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var lblPass: UILabel!
    @IBOutlet weak var lblSu: UILabel!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPass.isSecureTextEntry = true
        txtMail.delegate = self
        txtPass.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func signIn() {
        Auth.auth().signIn(withEmail: txtMail.text!, password: txtPass.text!) { (user, error) in
            if error == nil{
                let vc = MapViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpClick() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            if textField == txtMail {
                txtMail.resignFirstResponder()
                txtPass.becomeFirstResponder()
            } else {
                txtPass.resignFirstResponder()
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtMail {
            textField.returnKeyType = .next
        } else {
            textField.returnKeyType = .done
        }
        return true
    }
}
