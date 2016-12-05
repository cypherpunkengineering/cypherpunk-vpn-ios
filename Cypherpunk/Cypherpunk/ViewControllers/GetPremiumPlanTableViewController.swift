//
//  GetPremiumPlanTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class GetPremiumPlanTableViewController: UITableViewController {

    @IBOutlet weak var mailAddressField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension GetPremiumPlanTableViewController {
    
    @IBAction func monthlyUpgradeAction(_ sender: AnyObject) {

        mailAddressField.resignFirstResponder()
        
        if let address = mailAddressField.text , isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.upgrade(subscription: .monthly, expiredDate: Date()))
            
            if isModal() {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    
    @IBAction func semiannuallyUpgradeAction(_ sender: AnyObject) {

        mailAddressField.resignFirstResponder()
        
        if let address = mailAddressField.text , isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.upgrade(subscription: .semiannually, expiredDate: Date()))
            if isModal() {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func annuallyUpgradeAction(_ sender: AnyObject) {

        mailAddressField.resignFirstResponder()

        if let address = mailAddressField.text , isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.upgrade(subscription: .annually, expiredDate: Date()))
            if isModal() {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        }
        
        if self.presentingViewController?.presentedViewController == self {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}

extension GetPremiumPlanTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
