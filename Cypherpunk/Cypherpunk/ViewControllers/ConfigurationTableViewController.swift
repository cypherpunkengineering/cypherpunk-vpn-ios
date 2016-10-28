//
//  ConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift

class ConfigurationTableViewController: UITableViewController, StoreSubscriber {
    
    @IBOutlet weak var vpnAlwaysOnSwitch: UISwitch!
    @IBOutlet weak var autoConnectOnBootSwitch: UISwitch!
    @IBOutlet weak var vpnProtocolValueLabel: UILabel!
    
    
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
        vpnProtocolValueLabel.text = mainStore.state.settingsState.vpnProtocolMode.description
        vpnAlwaysOnSwitch.isOn = mainStore.state.settingsState.isAutoReconnect
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
        return 36
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func changeValueOfAutoConnectOnBootAction(_ sender: UISwitch) {
    }
    @IBAction func changeValueOfAlwaysOnAction(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoReconnect(isOn: sender.isOn))
    }

    func newState(state: AppState) {
        vpnProtocolValueLabel.text = state.settingsState.vpnProtocolMode.description
        vpnAlwaysOnSwitch.isOn = state.settingsState.isAutoReconnect
    }
}
