//
//  PadMenuTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/11/25.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift

class PadMenuTableViewController: UITableViewController {
    fileprivate enum Rows: Int {
        case account = 00
        case paymentUpgrade = 01
        case accountEmailDetail = 10
        case accountPasswordDetail = 11
        case autoConnectSettings = 20
        case protocolSettings = 30
        case get30daysPremiumFree = 40
        case rateOurService = 41
        case contactus = 42
        case help = 43
        case signOut = 44
    }
    
    @IBOutlet weak var usernameLabelButton: UIButton!
    @IBOutlet weak var mailAddressLabel: UILabel!
    @IBOutlet weak var vpnProtocolValueLabel: UILabel!

    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.tableView.reloadData()
        
        mainStore.subscribe(self)
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
        return super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        let titleLabel: UILabel
        titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 304, height: 36))
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.textColor = UIColor.goldenYellow
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)
        
        view.addSubview(titleLabel)
        
        return view
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let row = Rows(rawValue: (indexPath as NSIndexPath).section * 10 + (indexPath as NSIndexPath).row) {
            switch row {
            case .rateOurService:
                if let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appID)") {
                    UIApplication.shared.openURL(url)
                }
            case .contactus:
                let url = URL(string: "https://cypherpunk.zendesk.com/hc/requests/new")
                UIApplication.shared.openURL(url!)
            case .help:
                let url = URL(string: "https://support.cypherpunk.com/hc")
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
}

extension PadMenuTableViewController: StoreSubscriber {
    func newState(state: AppState) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.locale = Locale.current
        
        let accountState = state.accountState
        let dateString: String
        if let subscriptionType = accountState.subscriptionType {
            if let d = accountState.expiredDate {
                dateString = dateFormatter.string(from: d)
                expirationLabel.text = subscriptionType.detailMessage + " " + dateString
            } else {
                expirationLabel.text = subscriptionType.detailMessage
            }
        } else {
            expirationLabel.text = ""
        }
        
        if self.subscriptionTypeLabel.text?.lowercased() != state.accountState.accountType?.lowercased() {
            self.subscriptionTypeLabel.text = state.accountState.accountType?.capitalized
        }
        
        usernameLabelButton.setTitle(accountState.mailAddress, for: .normal)
        self.mailAddressLabel.text = state.accountState.mailAddress
        self.vpnProtocolValueLabel.text = state.settingsState.vpnProtocolMode.description

    }
}
