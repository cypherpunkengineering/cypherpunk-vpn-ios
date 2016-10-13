//
//  ManageTrustedNetworksTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/13.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ManageTrustedNetworksTableViewController: UITableViewController {

    private enum Section: Int {
        case autoSecure
        case otherNetworks
        case WifiNetworks
    }
    
    @IBOutlet weak var autoSecureSwitch: UISwitch!
    @IBOutlet weak var otherNetworksAutoSecureSwitch: UISwitch!
    
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == Section.WifiNetworks {
            // return wi-fi networks count
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Section(rawValue: indexPath.section) == Section.WifiNetworks {
            // return wi-fi networks count
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let section = Section(rawValue: section)!
        let titleLabel: UILabel
        titleLabel = UILabel(frame: CGRect(x: 15, y: 9, width: 300, height: 17))

        switch section {
        case .autoSecure:
            let descriptionLabel = UILabel(frame: CGRect(x: 15, y: 31, width: 300, height: 36))
            descriptionLabel.text = "Cypherpunk can automatically secure connections to untrusted networks."
            descriptionLabel.font = R.font.dosisMedium(size: 14)
            descriptionLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 0.6)
            descriptionLabel.numberOfLines = 0
            view.addSubview(descriptionLabel)
        case .otherNetworks:
            break
        case .WifiNetworks:
            let descriptionLabel = UILabel(frame: CGRect(x: 15, y: 31, width: 300, height: 36))
            descriptionLabel.text = "Add the networks you trust so Cypherpunk will now when connections should be secured."
            descriptionLabel.font = R.font.dosisMedium(size: 14)
            descriptionLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 0.6)
            descriptionLabel.numberOfLines = 0
            view.addSubview(descriptionLabel)
        }
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.textColor = UIColor.goldenYellowColor()
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section.rawValue)
        
        view.addSubview(titleLabel)
        
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = Section(rawValue: section)!
        
        switch section {
        case .autoSecure:
            return 80.0
        case .otherNetworks:
            return 40.0
        case .WifiNetworks:
            return 80.0
        }
    }
    
    @IBAction func valueChangedOfAutoSecureSwitchAction(_ sender: UISwitch) {
        print("AutoSecureSwitch is \(sender.isOn)")
    }
    
    @IBAction func valueChangedOfOtherNetworksAutoSecureSwitchAction(_ sender: UISwitch) {
        print("OtherNetworksAutoSecureSwitch is \(sender.isOn)")
    }
    
    
}
