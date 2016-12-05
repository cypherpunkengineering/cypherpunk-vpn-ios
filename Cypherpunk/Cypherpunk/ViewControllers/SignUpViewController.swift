//
//  SignUpViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/04.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift
import APIKit

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
        
        self.navigationController?.isNavigationBarHidden = true
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
        if let email = mailAddressField.text , isValidMailAddress(email), let password = passwordField.text {
            let request = SignUpRequest(email: email, password: password)
            
            Session.send(request) {
                (result) in
                switch result {
                case .success(let session):
                    mainStore.dispatch(AccountAction.signUp(mailAddress:email, session: session))
                    self.performSegue(withIdentifier: R.segue.signUpViewController.emailConfirmation, sender: nil)
                case .failure(let error):
                    print(error)
                }
            }

        }
    }
    
    func registerKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ sender: Notification) {
        if let userInfo = sender.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.size.height
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

    func newState(state: AppState)
    {
        if state.accountState.isLoggedIn == true {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
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
