//
//  ConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    fileprivate enum Rows: Int {
        case account = 00
        case paymentDetail = 10
        case paymentUpgrade = 11
        case accountEmailDetail = 20
        case accountPasswordDetail = 21
        case autoReconnect = 30
        case vpnProtocol = 31
        case contactus = 40
        case signOut = 41
    }
    
    @IBOutlet weak var usernameLabelButton: ThemedTintedNavigationButton!
    @IBOutlet weak var mailAddressLabel: UILabel!
    @IBOutlet weak var vpnProtocolDetailLabel: UILabel!
    @IBOutlet weak var autoConnectSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        let accountState = mainStore.state.accountState
        let settingsState = mainStore.state.settingsState
        mailAddressLabel.text = accountState.mailAddress ?? ""
        vpnProtocolDetailLabel.text = settingsState.vpnProtocolMode.description
        usernameLabelButton.setTitle(accountState.nickName, for: .normal)
        autoConnectSwitch.setOn(settingsState.isAutoReconnect, animated: false)
        self.tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if mainStore.state.accountState.isLoggedIn {
            return super.numberOfSections(in: tableView)
        }
        return super.numberOfSections(in: tableView) - 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var section = section
        if mainStore.state.accountState.isLoggedIn == false {
            section = section + 1
        }
        
        if section == 1 {
            // AccountType
            let accountState = mainStore.state.accountState
            switch accountState.subscriptionType {
            case .year:
                return 1
            default:
                return 2
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
        }
        
        let row = Rows(rawValue: (indexPath as NSIndexPath).section * 10 + (indexPath as NSIndexPath).row)!
        let cell: UITableViewCell
        switch row {
        case .paymentDetail:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            let accountState = mainStore.state.accountState
            let subscription = accountState.subscriptionType
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            
            let dateString: String
            if let d = accountState.expiredDate {
                dateString = dateFormatter.string(from: d)
            } else {
                dateString = ""
            }
            
            cell.textLabel?.text = subscription.title
            cell.detailTextLabel?.text = subscription.detailMessage + " " + dateString
        case .paymentUpgrade:
            let accountState = mainStore.state.accountState
            
            if accountState.isLoggedIn {
                cell = super.tableView(tableView, cellForRowAt: indexPath)
            } else {
                cell = super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section))
            }
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

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
        
        titleLabel.textColor = UIColor.white
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
        }

        if let row = Rows(rawValue: (indexPath as NSIndexPath).section * 10 + (indexPath as NSIndexPath).row) {
            switch row {
            case .signOut:
                let vc = R.storyboard.firstOpen.instantiateInitialViewController()
                mainStore.dispatch(AccountAction.logout)
                self.navigationController?.present(vc!, animated: true, completion: {
                    let _ = self.navigationController?.popViewController(animated: false)
                })
            default:
                break
            }
        } else {
            fatalError()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var indexPath = indexPath
        if mainStore.state.accountState.isLoggedIn == false {
            indexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        
    }
    
    @IBAction func changeAutoConnectAction(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoReconnect(isOn: sender.isOn))
    }
}
