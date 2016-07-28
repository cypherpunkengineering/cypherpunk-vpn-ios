//
//  TopViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ReachabilitySwift
import NetworkExtension

import ReSwift

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Connected: return "Connected"
        case .Connecting: return "Connecting"
        case .Disconnected: return "Disconnected"
        case .Disconnecting: return "Disconnecting"
        case .Invalid: return "Invalid"
        case .Reasserting: return "Reasserting"
        }
    }
}


class TopViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var IPAddressLabel: UILabel!
    
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var connectSwitch: UISwitch!
    
    @IBOutlet weak var regionButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        IPAddressLabel.text = NetworkInterface.Wifi.IPAddress ?? NetworkInterface.Cellular.IPAddress
        
        // Do any additional setup after loading the view.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NEVPNStatusDidChangeNotification,
            object: nil
        )
        
        regionButton.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        regionButton.titleLabel?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        regionButton.imageView?.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        
        regionButton.setTitle(mainStore.state.regionState.title, forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainStore.unsubscribe(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
    func didChangeVPNStatus(notification: NSNotification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        if connection.status == .Connected {
            mainStore.dispatch(RegionAction.Connect)
        }
        
        connectionStateLabel.text = String(connection.status)
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
    
    @IBAction func changeConnectStateAction(sender: AnyObject) {
        guard let connectionSwitch = sender as? UISwitch else {
            return
        }
        
        if connectionSwitch.on {
                VPNConfigurationCoordinator.start({
                    try! VPNConfigurationCoordinator.connect()
                })
        } else {
            VPNConfigurationCoordinator.disconnect()
        }
    }

    func newState(state: AppState) {
        regionButton.setTitle(state.regionState.title, forState: .Normal)
    }

}
