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
        titleLabel.textColor = UIColor.goldenYellow
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 , indexPath.row == 1 {
            return 44.0
        } else if indexPath.section == 1, indexPath.row == 1 {
            return 44.0
        }
        if indexPath.row == 0 {
            return 1.0
        }
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func newState(state: AppState) {
        vpnProtocolValueLabel.text = state.settingsState.vpnProtocolMode.description
    }
}
