//
//  UpdatePasswordTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/09/06.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import APIKit

class UpdatePasswordTableViewController: UITableViewController {

    @IBOutlet weak var newPasswordField: ThemedTextField!
    @IBOutlet weak var passwordConfirmationField: ThemedTextField!
    @IBOutlet weak var oldPasswordField: ThemedTextField!

    @IBOutlet weak var newPasswordLabel: ThemedLabel!
    @IBOutlet weak var passwordConfirmationLabel: ThemedLabel!
    @IBOutlet weak var oldPasswordLabel: ThemedLabel!

    var observer: NSObjectProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        observer = NotificationCenter.default.addObserver(
            forName: EditingRootDoneButtonPushedNotification,
            object: nil,
            queue: OperationQueue.main
            )
        { [weak self] notification in
            guard let `self` = self else {
                return
            }
            IndicatorView.show()
            if self.passwordConfirmationField.text == self.newPasswordField.text {
                let request = ChangePasswordRequest(
                    session: mainStore.state.accountState.session!,
                    newPassword: self.newPasswordField.text!,
                    oldPassword: self.oldPasswordField.text!)
                
                Session.send(request) {
                    (result) in
                    switch result {
                    case .success(let success):
                        if success {
                            // success
                            print("success")
                            IndicatorView.dismiss()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            // session expired
                            IndicatorView.dismiss()
                        }
                    case .failure(let error):
                        print(error)
                        IndicatorView.dismiss()
                        break
                    }
                }
                return
            }
            IndicatorView.dismiss()
        }

    }

    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func done() {
        IndicatorView.show()
        if self.passwordConfirmationField.text == self.newPasswordField.text {
            
                let request = ChangePasswordRequest(
                    session: mainStore.state.accountState.session!,
                    newPassword: self.newPasswordField.text!,
                    oldPassword: self.oldPasswordField.text!)
                
                Session.send(request) {
                    (result) in
                    switch result {
                    case .success(let success):
                        if success {
                            // success
                            print("success")
                            IndicatorView.dismiss()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            // session expired
                            IndicatorView.dismiss()
                        }
                    case .failure(let error):
                        print(error)
                        IndicatorView.dismiss()
                        break
                    }
                }
        }
        IndicatorView.dismiss()
    }

}

extension UpdatePasswordTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.newPasswordField:
            self.passwordConfirmationField.becomeFirstResponder()
        case self.passwordConfirmationField:
            self.oldPasswordField.becomeFirstResponder()
        case self.oldPasswordField:
            self.oldPasswordField.resignFirstResponder()
            self.done()
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        self.newPasswordLabel.textColor = UIColor.white
        self.passwordConfirmationLabel.textColor = UIColor.white
        
        var doneButtonIsEnabled = true
        
        switch textField {
        case self.newPasswordField:
            if newString?.characters.count == 0 {
                self.newPasswordLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
            if newString != self.passwordConfirmationLabel.text {
                passwordConfirmationLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
        case self.passwordConfirmationField:
            if newString?.characters.count == 0 {
                self.passwordConfirmationLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
            if newPasswordField.text != newString {
                passwordConfirmationLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
        case self.oldPasswordField:
            if newString?.characters.count == 0 {
                doneButtonIsEnabled = false
            }
            
            break
        default:
            break
        }
        
        if textField != self.oldPasswordField , self.oldPasswordField.text?.characters.count == 0 {
            doneButtonIsEnabled = false
        }
        
        NotificationCenter.default.post(name: EditingRootDoneButtonIsEnabledNotification, object: doneButtonIsEnabled)
        
        return true
    }
}
