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
        mainStore.dispatch(AccountAction.upgrade(subscription: .oneMonth, expiredDate: Date()))
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func upgradeTo6MonthSubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .halfYear, expiredDate: Date()))
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upgradeTo12MonthSubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .year, expiredDate: Date()))
        _ = self.navigationController?.popViewController(animated: true)
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
        case .oneMonth:
            return 2
        case .halfYear:
            return 1
        case .year:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free, .freePremium:
            return super.tableView(tableView, cellForRowAt: indexPath)
        case .oneMonth:
            return super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .halfYear:
            return super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 2))
        case .year:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free, .freePremium:
            return super.tableView(tableView, heightForRowAt: indexPath)
        case .oneMonth:
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .halfYear:
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 2))
        case .year:
            fatalError()
        }
    }
}
