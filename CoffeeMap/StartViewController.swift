//
//  RegisterViewController.swift
//  CoffeeMap
//
//  Created by Phan Tiến Anh on 8/19/20.
//  Copyright © 2020 Phan Tiến Anh. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signupClick() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signinClick() {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
