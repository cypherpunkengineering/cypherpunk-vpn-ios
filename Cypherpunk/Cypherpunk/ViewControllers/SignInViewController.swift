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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        mainStore.subscribe(self, selector: nil)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
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
        if let address = mailAddressField.text, let password = passwordField.text where isValidMailAddress(address) && password != "" {
            
            SVProgressHUD.show()
            
            let request = LoginRequest(login: address, password: password)
            Session.sendRequest(request) { result in
                
                switch result {
                case .Success(let response):
                    let listRequest = RegionListRequest(session: response.session)
                    Session.sendRequest(listRequest)
                    SVProgressHUD.dismiss()
                    mainStore.dispatch(LoginAction.Login(response: response))
                case .Failure(let error):
                    SVProgressHUD.showErrorWithStatus("\((error as NSError).localizedDescription)")
                }
            }

        }
    }
    
    func newState(state: AppState)
    {
        if state.loginState.isLoggedIn {
            // TODO: transition to send email screen
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}

extension SignInViewController {
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                bottomSpaceConstraint.constant = keyboardHeight
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        bottomSpaceConstraint.constant = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
    }
    
    func registerKeyboardNotification() {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        
        defaultCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

}

extension SignInViewController: UITextFieldDelegate {
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