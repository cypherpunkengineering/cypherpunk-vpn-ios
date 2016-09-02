//
//  AccountViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {

    @IBOutlet weak var mailLabelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        mailLabelButton.setTitle(mainStore.state.accountState.mailAddress, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
