//
//  LoginViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var mailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func loginAction() {
        if let address = mailAddressField.text, let password = passwordField.text where isValidMailAddress(address) && password != "" {
            mainStore.dispatch(LoginAction.Login(mailAddress: address, password: password))
        }
    }

}
