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
    
    @IBAction func upgradeToPerMonthlySubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.Upgrade(subscription: .OneMonth, expiredDate: Date()))
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func upgradeTo6MonthSubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.Upgrade(subscription: .HalfYear, expiredDate: Date()))
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upgradeTo12MonthSubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.Upgrade(subscription: .Year, expiredDate: Date()))
        self.navigationController?.popViewController(animated: true)
    }
}

extension UpgradeSelectTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .Free, .FreePremium:
            return super.tableView(tableView, cellForRowAt: indexPath)
        case .OneMonth:
            return super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .HalfYear:
            return super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 2))
        case .Year:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .Free, .FreePremium:
            return super.tableView(tableView, heightForRowAt: indexPath)
        case .OneMonth:
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .HalfYear:
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 2))
        case .Year:
            fatalError()
        }
    }
}
