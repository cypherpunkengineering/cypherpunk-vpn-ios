//
//  UpgradeSelectTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class UpgradeSelectTableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upgradeToPerMonthlySubscriptionAction(sender: AnyObject) {
        mainStore.dispatch(AccountAction.Upgrade(subscription: .OneMonth, expiredDate: NSDate()))
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func upgradeTo6MonthSubscriptionAction(sender: AnyObject) {
        mainStore.dispatch(AccountAction.Upgrade(subscription: .HalfYear, expiredDate: NSDate()))
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func upgradeTo12MonthSubscriptionAction(sender: AnyObject) {
        mainStore.dispatch(AccountAction.Upgrade(subscription: .Year, expiredDate: NSDate()))
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension UpgradeSelectTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .Free:
            return 3
        case .FreePremium:
            return 3
        case .OneMonth:
            return 2
        case .HalfYear:
            return 1
        case .Year:
            fatalError()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .Free, .FreePremium:
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        case .OneMonth:
            return super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1))
        case .HalfYear:
            return super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 2))
        case .Year:
            fatalError()
        }
    }
}
