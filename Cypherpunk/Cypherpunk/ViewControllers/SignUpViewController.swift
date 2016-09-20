//
//  SignUpViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/04.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift

class SignUpViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var mailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        self.registerKeyboardNotification()
        mainStore.subscribe(self, selector: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
        mainStore.unsubscribe(self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction() {
        signUp()
    }
    
    func signUp() {
        if let address = mailAddressField.text , isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.SignUp(mailAddress: address))
        }
    }
    
    func registerKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).CGRectValue.size.height {
                bottomSpaceConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(_ sender: Notification) {
        bottomSpaceConstraint.constant = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
    }

    func removeKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func newState(_ state: AppState)
    {
        if state.accountState.isLoggedIn == true {
            // TODO: transition to send email screen
            self.dismiss(animated: true, completion: nil)
        }
    }

}


extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField == mailAddressField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signUp()
        }
        
        return true
    }
}
