//
//  SettingsStatusViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class SettingsStatusViewController: UITableViewController, PageContent {

    var pageIndex: Int = 1
    
    @IBOutlet weak var connectionTimeLabelButton: UIButton!
    
    @IBOutlet weak var originalIPAddressLabel: UILabel!
    @IBOutlet weak var originalLocaleLabelButton: UIButton!

    @IBOutlet weak var newIPAddressLabel: UILabel!
    @IBOutlet weak var newLocalLabelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeIPAddressAction(sender: AnyObject) {
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleLabel.textColor = UIColor(red: 204.0 / 255.0 , green: 204.0 / 255.0 , blue: 204.0 / 255.0 , alpha: 1.0)
        
        view.addSubview(titleLabel)
        
        return view
    }

}
