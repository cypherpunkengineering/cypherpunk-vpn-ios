//
//  SettingsStatusViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

class SettingsStatusViewController: UITableViewController, PageContent {

    var pageIndex: Int = 1
    
    @IBOutlet weak var connectionTimeLabelButton: UIButton!
    
    @IBOutlet weak var originalIPAddressLabel: UILabel!
    @IBOutlet weak var originalLocaleLabelButton: UIButton!

    @IBOutlet weak var disconnectedLabel: UILabel!
    @IBOutlet weak var connectedTimeView: UIView!
    @IBOutlet weak var newIPAddressLabel: UILabel!
    @IBOutlet weak var newLocalLabelButton: UIButton!
    
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
        self.title = "Connection Status"

        let status = NEVPNManager.sharedManager().connection.status
        if status == .Connected {
            connectedTimeView.hidden = false
            disconnectedLabel.hidden = true
        } else {
            connectedTimeView.hidden = true
            disconnectedLabel.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeIPAddressAction(sender: AnyObject) {
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let status = NEVPNManager.sharedManager().connection.status
        if status == .Connected {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return 4
        }
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

}
