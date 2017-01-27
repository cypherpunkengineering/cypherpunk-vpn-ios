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
                        let alert = UIAlertController(title: "Unable to Update Password",
                                                      message: "Password could not be updated. Please verify that your current password is correct.",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                }
                return
            }
            IndicatorView.dismiss()
        }
        
        // Trick to hide the empty table cells that usually show in UITableView
        self.tableView.tableFooterView = UIView()
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

        var doneButtonIsEnabled = true
        if let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            self.newPasswordLabel.textColor = UIColor.white
            self.passwordConfirmationLabel.textColor = UIColor.white
            
            
            switch textField {
            case self.newPasswordField:
                if newString.characters.count < 6 {
                    self.newPasswordLabel.textColor = UIColor.red
                    doneButtonIsEnabled = false
                }
                
                if newString != self.passwordConfirmationLabel.text {
                    passwordConfirmationLabel.textColor = UIColor.red
                    doneButtonIsEnabled = false
                }
                
            case self.passwordConfirmationField:
                if newString.characters.count < 6 {
                    self.passwordConfirmationLabel.textColor = UIColor.red
                    doneButtonIsEnabled = false
                }
                
                if newPasswordField.text != newString {
                    passwordConfirmationLabel.textColor = UIColor.red
                    doneButtonIsEnabled = false
                }
                
            case self.oldPasswordField:
                if newString.characters.count < 6 {
                    doneButtonIsEnabled = false
                }
                
                break
            default:
                break
            }
            
            if textField != self.oldPasswordField, let text = oldPasswordField.text, text.characters.count < 6 {
                doneButtonIsEnabled = false
            }
    
        } else {
            doneButtonIsEnabled = false
        }
        
        NotificationCenter.default.post(name: EditingRootDoneButtonIsEnabledNotification, object: doneButtonIsEnabled)
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // this adds the space above the Password field
        if section == 1 {
            return 40
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let transparentView = UIView(frame: CGRect(x: 0, y: 0.0, width: 200.0, height: 40.0))
            transparentView.backgroundColor = UIColor.clear
            
            let label = UILabel()
            label.text = "Input current password to update your password."
            label.font = R.font.dosisRegular(size: 14)
            label.textColor = UIColor.white.withAlphaComponent(0.6)
            label.frame.origin.x = 15
            label.frame.origin.y = 15
            
            transparentView.addSubview(label)
            label.sizeToFit()
            
            return transparentView
        }
        else {
            return nil
        }
    }
}
