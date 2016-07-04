//
//  SignUpViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/04.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, HasShownKeyboardType {

    @IBOutlet weak var mailAddressField: UITextField!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction() {
        signUp()
    }
    
    func signUp() {
        if let address = mailAddressField.text where isValidMailAddress(address) {
            mainStore.dispatch(LoginAction.SignUp(mailAddress: address))
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        if textField == mailAddressField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signIn()
        }
        
        return true
    }
}
