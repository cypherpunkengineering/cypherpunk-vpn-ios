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
        case accountEmailDetail = 10
        case accountPasswordDetail = 11
        case get30daysPremiumFree = 20
        case rateOurService = 21
        case contactus = 22
        case help = 23
        case signOut = 24
    }
    
    @IBOutlet weak var usernameLabelButton: UIButton!
    @IBOutlet weak var mailAddressLabel: UILabel!

    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!

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
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        let titleLabel: UILabel
        titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 304, height: 36))
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.textColor = UIColor.goldenYellowColor()
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 36
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

