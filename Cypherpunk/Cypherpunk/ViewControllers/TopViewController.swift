//
//  TopViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReachabilitySwift

class TopViewController: UIViewController {

    @IBOutlet weak var IPAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        IPAddressLabel.text = NetworkInterface.Wifi.IPAddress ?? NetworkInterface.Cellular.IPAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func drawerToggleAction(sender: AnyObject) {
        let notification = NSNotification(name: CKNavDrawerActionNotification.Open, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }

}