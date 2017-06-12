//
//  AccountConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift

class AccountConfigurationTableViewController: UITableViewController {
    
    fileprivate enum Rows: Int {
        case account = 10
        case paymentUpgrade = 20
        case accountEmailDetail = 30
        case accountPasswordDetail = 40
        case get30daysPremiumFree = 50
        case rateOurService = 60
        case contactus = 70
        case help = 80
        case signOut = 90
        case share = 100
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.tableView.isScrollEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false

        let menuCellNib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        self.tableView.register(menuCellNib, forCellReuseIdentifier: "MenuCell")
        
        let accountDetailNib = UINib(nibName: "AccountDetailTableViewCell", bundle: nil)
        self.tableView.register(accountDetailNib, forCellReuseIdentifier: "AccountDetailCell")

        mainStore.subscribe(self)
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // account detail, account settings, more
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            // depending on the type of account and plan the upgrade button may not be shown
            return shouldHideUpgradeMenuItem() ? 2 : 3
        case 2:
            return 5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: UIView?
        
        if section > 0 {
            view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
            let titleLabel: UILabel
            titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 304, height: 36))
            titleLabel.font = R.font.dosisMedium(size: 13)
            titleLabel.textColor = UIColor.peach
            titleLabel.text = section == 1 ? "Account Settings" : "More"
            
            view?.addSubview(titleLabel)
        }

        return view // section 0 will have a nil header view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "AccountDetailCell")
        }
        else {
            // special handling for account settings because upgrade button is not always shown
            cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")
            
            if indexPath.section == 1 {
                setupCellForAccountSettingsSection(row: indexPath.row, cell: cell!)
            }
            else if indexPath.section == 2 {
                setupCellForMoreSection(row: indexPath.row, cell: cell!)
            }
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 36
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 104.5
        default:
            return 44.0
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tableRow = tableView.cellForRow(at: indexPath)
        
        if let row = Rows(rawValue: (tableRow?.tag)!) {
            switch row {
            case .paymentUpgrade:
                self.performSegue(withIdentifier: "ShowUpgrade", sender: self)
            case .accountEmailDetail:
                self.performSegue(withIdentifier: "ShowEmail", sender: self)
            case .accountPasswordDetail:
                self.performSegue(withIdentifier: "ShowPassword", sender: self)
            case .share:
                self.performSegue(withIdentifier: "ShowShare", sender: self)
            case .rateOurService:
                if let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appID)") {
                    UIApplication.shared.openURL(url)
                }
            case .contactus:
                let url = URL(string: "https://cypherpunk.com/support/request/new")
                UIApplication.shared.openURL(url!)
            case .help:
                let url = URL(string: "https://cypherpunk.com/support")
                UIApplication.shared.openURL(url!)
            case .signOut:
                mainStore.dispatch(AccountAction.logout)
                
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    let vc = R.storyboard.firstOpen.instantiateInitialViewController()
                    UIApplication.shared.delegate!.window!?.rootViewController!.present(vc!, animated: true) {
                        NotificationCenter.default.post(name: kResetCenterViewNotification, object: nil)
                    }
                    
                } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    let vc = R.storyboard.firstOpen_iPad.instantiateInitialViewController()
                    UIApplication.shared.delegate!.window!?.rootViewController!.present(vc!, animated: true) {
                        NotificationCenter.default.post(name: kResetCenterViewNotification, object: nil)
                    }
                }
            default:
                break
            }
        } else {
            fatalError()
        }
        
    }
    
    private func shouldHideUpgradeMenuItem() -> Bool {
        // if the plan is annual or forever or the account type is developer, don't show the upgrade button
        let accountState = mainStore.state.accountState
        return accountState.isDeveloperAccount || !accountState.isSubscriptionUpgradeable
    }
    
    private func setupCellForAccountSettingsSection(row: Int, cell: UITableViewCell) {
        // this section will be either
        // Upgrade, Email, Password OR
        // Email, Password
        switch row {
        case 0:
            if shouldHideUpgradeMenuItem() {
                cell.textLabel?.text = "Email"
                cell.tag = Rows.accountEmailDetail.rawValue
            }
            else {
                let premium = mainStore.state.accountState.isPremiumAccount
                cell.textLabel?.text = premium ? "Change Plan" : "Upgrade"
                cell.tag = Rows.paymentUpgrade.rawValue
            }
        case 1:
            if shouldHideUpgradeMenuItem() {
                cell.textLabel?.text = "Password"
                cell.tag = Rows.accountPasswordDetail.rawValue
            }
            else {
                cell.textLabel?.text = "Email"
                cell.tag = Rows.accountEmailDetail.rawValue
            }
        case 2:
            cell.textLabel?.text = "Password"
            cell.tag = Rows.accountPasswordDetail.rawValue
        default:
            break
        }
    }
    
    private func setupCellForMoreSection(row: Int, cell: UITableViewCell) {
        switch row {
        case 0:
            cell.textLabel?.text = "Share With Your Friends"
            cell.tag = Rows.share.rawValue
        case 1:
            cell.textLabel?.text = "Rate Our Service"
            cell.tag = Rows.rateOurService.rawValue
        case 2:
            cell.textLabel?.text = "Contact the Founders"
            cell.tag = Rows.contactus.rawValue
            cell.accessoryType = .none
        case 3:
            cell.textLabel?.text = "Help"
            cell.tag = Rows.help.rawValue
        case 4:
            cell.textLabel?.text = "Log out"
            cell.tag = Rows.signOut.rawValue
            cell.accessoryType = .none
        default:
            break
        }
    }
}

extension AccountConfigurationTableViewController: StoreSubscriber {
    func newState(state: AppState) {
        self.tableView.reloadSections([0, 1], with: .automatic)
    }
}
