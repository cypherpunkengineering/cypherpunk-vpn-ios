//
//  SettingsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PageContent {
    
    private enum Section: Int {
        case HelpMeChoose
        case Settings
        case About
    }
        
    var pageIndex: Int = 0
    
    @IBOutlet weak var versionValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        versionValueLabel.text = "\(version!)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)

        titleLabel.textColor = UIColor(red: 204.0 / 255.0 , green: 204.0 / 255.0 , blue: 204.0 / 255.0 , alpha: 1.0)
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}