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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension GetPremiumPlanTableViewController {
    
    @IBAction func oneMonthUpgradeAction(sender: AnyObject) {

        mailAddressField.resignFirstResponder()
        
        if let address = mailAddressField.text where isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.SignUp(mailAddress: address))
            mainStore.dispatch(AccountAction.Upgrade(subscription: .OneMonth, expiredDate: NSDate()))
            
            if isModal() {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    
    @IBAction func halfYearUpgradeAction(sender: AnyObject) {

        mailAddressField.resignFirstResponder()
        
        if let address = mailAddressField.text where isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.SignUp(mailAddress: address))
            mainStore.dispatch(AccountAction.Upgrade(subscription: .HalfYear, expiredDate: NSDate()))
            if isModal() {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func yearUpgradeAction(sender: AnyObject) {

        mailAddressField.resignFirstResponder()

        if let address = mailAddressField.text where isValidMailAddress(address) {
            mainStore.dispatch(AccountAction.SignUp(mailAddress: address))
            mainStore.dispatch(AccountAction.Upgrade(subscription: .Year, expiredDate: NSDate()))
            if isModal() {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
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
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}