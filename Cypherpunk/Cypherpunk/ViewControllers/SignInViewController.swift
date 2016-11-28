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
import RealmSwift
import SVProgressHUD

class SignInViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var mailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
            Session.send(request, callbackQueue: nil, handler: { (result) in
                switch result {
                case .success(let response):
                    let regionRequest = RegionListRequest(session: response.session, accountType: response.account.type)
                    Session.send(regionRequest) { (result) in
                        switch result {
                        case .success(_):
                            
                            let subscriptionRequest = SubscriptionStatusRequest(session: response.session)
                            Session.send(subscriptionRequest) {
                                (result) in
                                switch result {
                                case .success(let status):
                                    
                                    mainStore.dispatch(AccountAction.getSubscriptionStatus(status: status))
                                    
                                    let realm = try! Realm()
                                    if let region = realm.objects(Region.self).first {
                                        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.name, serverIP: region.ipsecDefault, countryCode: region.country, remoteIdentifier: region.ipsecHostname))
                                    }
                                    mainStore.dispatch(AccountAction.login(response: response))
                                case .failure(let error):
                                    SVProgressHUD.showError(withStatus: "\((error as NSError).localizedDescription)")
                                }
                            }
                            
                        case .failure(let error):
                            SVProgressHUD.showError(withStatus: "\((error as NSError).localizedDescription)")
                        }
                        IndicatorView.dismiss()
                    }
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: "\((error as NSError).localizedDescription)")
                    IndicatorView.dismiss()
                }
                
            })
            
        }
    }
    
    func newState(state: AppState)
    {
        if state.accountState.isLoggedIn {
            // TODO: transition to send email screen
            let destination = R.storyboard.walkthrough.instantiateInitialViewController()
            self.navigationController?.pushViewController(destination!, animated: true)
        }
    }
    
    @IBAction func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
}

extension SignInViewController {
    
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
