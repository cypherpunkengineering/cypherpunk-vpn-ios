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
        case paymentUpgrade = 01
        case accountHeader = 10
        case accountEmailDetail = 11
        case accountPasswordDetail = 12
        case moreHeader = 20
        case get30daysPremiumFree = 21
        case rateOurService = 22
        case contactus = 23
        case help = 24
        case signOut = 25
    }
    
    @IBOutlet weak var usernameLabelButton: UIButton!
    @IBOutlet weak var mailAddressLabel: UILabel!

    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.tableView.isScrollEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        let accountState = mainStore.state.accountState
        mailAddressLabel.text = accountState.mailAddress ?? ""
        usernameLabelButton.setTitle(accountState.mailAddress, for: .normal)
        let subscription = accountState.subscriptionType
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        let dateString: String
        if let d = accountState.expiredDate {
            dateString = dateFormatter.string(from: d)
        } else {
            dateString = ""
        }
        
        subscriptionTypeLabel.text = subscription.title
        expirationLabel.text = subscription.detailMessage + " " + dateString

        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let row = Rows(rawValue: (indexPath as NSIndexPath).section * 10 + (indexPath as NSIndexPath).row) {
            switch row {
            case .rateOurService:
                if let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appID)") {
                    UIApplication.shared.openURL(url)
                }
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
}

