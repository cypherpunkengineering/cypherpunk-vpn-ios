//
//  ConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    private enum Rows: Int {
        case Account = 00
        case PaymentDetail = 10
        case PaymentUpgrade = 11
        case AccountEmailDetail = 20
        case AccountPasswordDetail = 21
        case AutoReconnect = 30
        case VPNProtocol = 31
        case Contactus = 40
        case SignOut = 41
    }
    
    @IBOutlet weak var usernameLabelButton: ThemedTintedNavigationButton!
    @IBOutlet weak var mailAddressLabel: UILabel!
    @IBOutlet weak var vpnProtocolDetailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        let accountState = mainStore.state.accountState
        mailAddressLabel.text = accountState.mailAddress
        vpnProtocolDetailLabel.text = mainStore.state.settingsState.vpnProtocolMode.description
        usernameLabelButton.setTitle(accountState.nickName, forState: .Normal)
        self.tableView.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if mainStore.state.accountState.isLoggedIn {
            return super.numberOfSectionsInTableView(tableView)
        }
        return super.numberOfSectionsInTableView(tableView) - 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var section = section
        if mainStore.state.accountState.isLoggedIn == false {
            section = section + 1
        }
        
        if section == 1 {
            // AccountType
            let accountState = mainStore.state.accountState
            switch accountState.subscriptionType {
            case .Year:
                return 1
            default:
                return 2
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
        }
        
        let row = Rows(rawValue: indexPath.section * 10 + indexPath.row)!
        let cell: UITableViewCell
        switch row {
        case .PaymentDetail:
            cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            
            let accountState = mainStore.state.accountState
            let subscription = accountState.subscriptionType
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            
            let dateString: String
            if let d = accountState.expiredDate {
                dateString = dateFormatter.stringFromDate(d)
            } else {
                dateString = ""
            }
            
            cell.textLabel?.text = subscription.title
            cell.detailTextLabel?.text = subscription.detailMessage + " " + dateString
        case .PaymentUpgrade:
            let accountState = mainStore.state.accountState
            
            if accountState.isLoggedIn {
                cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            } else {
                cell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section))
            }
        default:
            cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel: UILabel
        if section == 0 {
            titleLabel = UILabel(frame: CGRect(x: 15, y: 26, width: 300, height: 17))
        } else {
            titleLabel = UILabel(frame: CGRect(x: 15, y: 9, width: 300, height: 17))
        }

        var section = section
        if mainStore.state.accountState.isLoggedIn == false {
            section = section + 1
        }
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)
        
        let theme = mainStore.state.themeState.themeType
        switch theme {
        case .White:
            titleLabel.textColor = UIColor.whiteThemeTextColor()
        case .Black:
            titleLabel.textColor = UIColor.whiteThemeIndicatorColor()
        case .Indigo:
            titleLabel.textColor = UIColor.whiteColor()
        }
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
        }

        if let row = Rows(rawValue: indexPath.section * 10 + indexPath.row) {
            switch row {
            case .SignOut:
                let vc = R.storyboard.firstOpen.initialViewController()
                mainStore.dispatch(AccountAction.Logout)
                self.navigationController?.presentViewController(vc!, animated: true, completion: {
                    self.navigationController?.popViewControllerAnimated(false)
                })
            default:
                break
            }
        } else {
            fatalError()
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
        }
        
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        
    }
}