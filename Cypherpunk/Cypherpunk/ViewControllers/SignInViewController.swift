//
//  SignInViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import SafariServices

import APIKit
import ReSwift

import SVProgressHUD

class SignInViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var mailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailAddressField.text = "test@test.test"
        passwordField.text = "test123"
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        mainStore.subscribe(self, selector: nil)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
        removeKeyboardNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signInAction() {
        signIn()
    }

    func signIn() {
        if let address = mailAddressField.text, let password = passwordField.text , isValidMailAddress(address) && password != "" {

            IndicatorView.show()
            
            let request = LoginRequest(login: address, password: password)
            Session.sendRequest(request) { result in
                
                switch result {
                case .Success(let response):
                    mainStore.dispatch(AccountAction.Login(response: response))
                case .Failure(let error):
                    SVProgressHUD.showErrorWithStatus("\((error as NSError).localizedDescription)")
                }
                
                IndicatorView.dismiss()
            }

        }
    }
    
    func newState(_ state: AppState)
    {
        if state.accountState.isLoggedIn {
            // TODO: transition to send email screen
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension SignInViewController {
    
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
    
    func registerKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField == mailAddressField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signIn()
        }
        
        return true
    }
}
