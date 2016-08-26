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
        
        let loginstate = mainStore.state.loginState
        mailAddressLabel.text = loginstate.mailAddress
        vpnProtocolDetailLabel.text = mainStore.state.settingsState.vpnProtocolMode.description
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 9, width: 300, height: 17))
        
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
        if let row = Rows(rawValue: indexPath.section * 10 + indexPath.row) {
            switch row {
            case .Contactus:
                self.navigationController?.pushViewController(contactUs!, animated: true)
            case .SignOut:
                let vc = R.storyboard.firstOpen.initialViewController()
                mainStore.dispatch(LoginAction.Logout)
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


}