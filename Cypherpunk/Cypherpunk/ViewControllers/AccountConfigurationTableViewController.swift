//
//  AccountConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class AccountConfigurationTableViewController: UITableViewController {

    fileprivate enum Rows: Int {
        case account = 00
        case paymentDetail = 10
        case paymentUpgrade = 11
        case accountEmailDetail = 20
        case accountPasswordDetail = 21
        case contactus = 30
        case signOut = 31
    }

    @IBOutlet weak var usernameLabelButton: ThemedTintedNavigationButton!
    @IBOutlet weak var mailAddressLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let barbutton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        barbutton.setTitleTextAttributes([
            NSFontAttributeName: R.font.dosisMedium(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.goldenYellowColor()
            ], for: .normal)
        self.navigationItem.rightBarButtonItem = barbutton
        self.closeButton = barbutton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        let accountState = mainStore.state.accountState
        mailAddressLabel.text = accountState.mailAddress ?? ""
        usernameLabelButton.setTitle(accountState.nickName, for: .normal)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
                mainStore.dispatch(AccountAction.logout)
                
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    let vc = R.storyboard.firstOpen.instantiateInitialViewController()
                    UIApplication.shared.delegate!.window!?.rootViewController!.present(vc!, animated: true) {
                        let _ = self.navigationController?.popViewController(animated: false)
                    }
                    
                } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    let vc = R.storyboard.firstOpen_iPad.instantiateInitialViewController()
                    self.navigationController?.dismiss(animated: false) {
                        UIApplication.shared.delegate!.window!?.rootViewController!.present(vc!, animated: true, completion: nil)
                    }
                }
                
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
}

extension AccountConfigurationTableViewController {
    @IBAction func closeAction() {
        self.navigationController?.dismiss(animated: true)
    }
}
