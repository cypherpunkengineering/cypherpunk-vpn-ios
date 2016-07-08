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
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mailAddressField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                               attributes:[NSForegroundColorAttributeName: UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0)])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerKeyboardNotification()
        mainStore.subscribe(self, selector: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
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
        if let address = mailAddressField.text where isValidMailAddress(address) {
            mainStore.dispatch(LoginAction.SignUp(mailAddress: address))
        }
    }
    
    func registerKeyboardNotification() {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

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

    func removeKeyboardNotification() {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        
        defaultCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func newState(state: AppState)
    {
        if state.loginState.mailAddress != "" {
            // TODO: transition to send email screen
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        signUp()
        
        return true
    }
}
