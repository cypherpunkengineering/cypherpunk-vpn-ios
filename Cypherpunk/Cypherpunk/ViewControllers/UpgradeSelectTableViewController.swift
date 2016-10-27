//
//  UpgradeSelectTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class UpgradeSelectTableViewController: UITableViewController {

    @IBOutlet weak var oneMonthCellContentView: UIView!
    @IBOutlet weak var oneMonthCurrentPlanLabelView: UIView!
    
    @IBOutlet weak var halfYearCellContentView: UIView!
    @IBOutlet weak var halfYearCurrentPlanLabelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        switch mainStore.state.accountState.subscriptionType {
        case .oneMonth:
            oneMonthCellContentView.alpha = 0.5
            oneMonthCellContentView.isUserInteractionEnabled = false
            oneMonthCurrentPlanLabelView.isHidden = false
        case .halfYear:
            halfYearCellContentView.alpha = 0.5
            halfYearCellContentView.isUserInteractionEnabled = false
            halfYearCurrentPlanLabelView.isHidden = false
        default:
            break
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upgradeToPerMonthlySubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .oneMonth, expiredDate: Date()))
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func upgradeTo6MonthSubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .halfYear, expiredDate: Date()))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeTo12MonthSubscriptionAction(_ sender: AnyObject) {
        mainStore.dispatch(AccountAction.upgrade(subscription: .year, expiredDate: Date()))
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
        case .oneMonth:
            return 3
        case .halfYear:
            return 2
        case .year:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free, .freePremium, .oneMonth:
            return super.tableView(tableView, cellForRowAt: indexPath)
        case .halfYear:
            return super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .year:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let accountState = mainStore.state.accountState
        
        switch accountState.subscriptionType {
        case .free, .freePremium, .oneMonth:
            return super.tableView(tableView, heightForRowAt: indexPath)
        case .halfYear:
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        case .year:
            fatalError()
        }
    }
}
