//
//  UpgradeSelectTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class UpgradeSelectTableViewController: UITableViewController {

    @IBOutlet weak var monthlyCellContentView: UIView!
    @IBOutlet weak var monthlyCurrentPlanLabelView: UIView!
    
    @IBOutlet weak var semiannuallyCellContentView: UIView!
    @IBOutlet weak var semiannuallyCurrentPlanLabelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        switch mainStore.state.accountState.subscriptionType {
        case .monthly:
            monthlyCellContentView.alpha = 0.5
            monthlyCellContentView.isUserInteractionEnabled = false
            monthlyCurrentPlanLabelView.isHidden = false
        case .semiannually:
            semiannuallyCellContentView.alpha = 0.5
            semiannuallyCellContentView.isUserInteractionEnabled = false
            semiannuallyCurrentPlanLabelView.isHidden = false
        default:
            break
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upgradeToMonthlySubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .monthly, expiredDate: Date()))
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func upgradeToSemiannuallySubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .semiannually, expiredDate: Date()))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeToAnnuallySubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .annually, expiredDate: Date()))
        self.dismiss(animated: true, completion: nil)
    }
}

extension UpgradeSelectTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free:
            return 3
        case .freePremium:
            return 3
        case .monthly:
            return 3
        case .semiannually:
            return 2
        case .annually:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free, .freePremium, .monthly:
            return super.tableView(tableView, cellForRowAt: indexPath)
        case .semiannually:
            return super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .annually:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free, .freePremium, .monthly:
            return super.tableView(tableView, heightForRowAt: indexPath)
        case .semiannually:
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .annually:
            fatalError()
        }
    }
}
