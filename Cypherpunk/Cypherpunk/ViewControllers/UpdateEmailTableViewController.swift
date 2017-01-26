//
//  UpdateEmailTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import APIKit

class UpdateEmailTableViewController: UITableViewController {
    
    @IBOutlet weak var newEmailField: ThemedTextField!
    @IBOutlet weak var emailConfirmationField: ThemedTextField!
    @IBOutlet weak var passwordField: ThemedTextField!
    
    @IBOutlet weak var newEmailLabel: ThemedLabel!
    @IBOutlet weak var emailConfirmationLabel: ThemedLabel!
    @IBOutlet weak var passwordLabel: ThemedLabel!
    
    var observer: NSObjectProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.done()
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
        if self.emailConfirmationField.text == self.newEmailField.text {
            let request = ChangeEmailRequest(session: mainStore.state.accountState.session!,
                                             newMailAddress: self.newEmailField.text!,
                                             password: self.passwordLabel.text!)
            Session.send(request) {
                (result) in
                switch result {
                case .success(let success):
                    if success {
                        // success
                        IndicatorView.dismiss()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // session expired
                    }
                case .failure(let error):
                    print(error)
                    IndicatorView.dismiss()
                    
                    let alert = UIAlertController(title: "Unable to Update Email",
                                                  message: "Email address is already in use or password is incorrect.",
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
}

extension UpdateEmailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.newEmailField:
            self.emailConfirmationField.becomeFirstResponder()
        case self.emailConfirmationField:
            self.passwordField.becomeFirstResponder()
        case self.passwordField:
            self.passwordField.resignFirstResponder()
            self.done()
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        self.newEmailLabel.textColor = UIColor.white
        self.emailConfirmationLabel.textColor = UIColor.white
        
        var doneButtonIsEnabled = true
        
        switch textField {
        case self.newEmailField:
            if isValidMailAddress(newString!) == false {
                self.newEmailLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
            if newString != self.emailConfirmationLabel.text {
                emailConfirmationLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
        case self.emailConfirmationField:
            if isValidMailAddress(newString!) == false {
                self.emailConfirmationLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
            if newEmailField.text != newString {
                emailConfirmationLabel.textColor = UIColor.red
                doneButtonIsEnabled = false
            }
            
        case self.passwordField:
            if let newString = newString {
                if newString.characters.count < 6 {
                    doneButtonIsEnabled = false
                }
            } else {
                doneButtonIsEnabled = false
            }
            
            break
        default:
            break
        }
        
        if textField != self.passwordField , (self.passwordField.text?.characters.count)! < 6 {
            doneButtonIsEnabled = false
        }
        
        NotificationCenter.default.post(name: EditingRootDoneButtonIsEnabledNotification, object: doneButtonIsEnabled)
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // this adds the space above the Password field
        if section == 1 {
            return 20
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let transparentView = UIView(frame: CGRect(x: 0, y: 0.0, width: 100.0, height: 20.0))
            transparentView.backgroundColor = UIColor.clear
            return transparentView
        }
        else {
            return nil
        }
    }
}
