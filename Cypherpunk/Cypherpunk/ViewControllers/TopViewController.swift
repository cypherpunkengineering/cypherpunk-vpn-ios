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
        case .Connected: return "You are now protected"
        case .Connecting: return "CONNECTING..."
        case .Disconnected: return "Touch to Start"
        case .Disconnecting: return "DISCONNECTING..."
        case .Invalid: return "INVALID"
        case .Reasserting: return "REASSERTING"
        }
    }
}

class TopViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var connectedButton: UIButton!
    @IBOutlet weak var connectingButton: UIButton!
    @IBOutlet weak var disconnectedButton: UIButton!
    @IBOutlet weak var outsideCircleView: UIView!
    @IBOutlet weak var connectionStateLabel: UILabel!
    
    @IBOutlet weak var cancelEmbededView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var regionButton: UIButton!
    
    internal var connectionObserver: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NEVPNStatusDidChangeNotification,
            object: nil
        )
    
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        let cancelAttributed = NSAttributedString(string: "Cancel", attributes: attributes)
        cancelButton.setAttributedTitle(cancelAttributed, forState: .Normal)
        regionButton.setTitle(mainStore.state.regionState.title, forState: .Normal)
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true

        VPNConfigurationCoordinator.load {
            let status = NEVPNManager.sharedManager().connection.status
            self.updateViewWithVPNStatus(status)
        }
        
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
    
    func updateViewWithVPNStatus(status: NEVPNStatus) {
        switch status {
        case .Connected:
            outsideCircleView.backgroundColor = UIColor(red: 110.0 / 255.0 , green: 201.0 / 255.0 , blue: 9.0 / 255.0 , alpha: 0.60)
            connectedButton.hidden = false
            connectingButton.hidden = true
            disconnectedButton.hidden = true
            disconnectedButton.enabled = true
            cancelEmbededView.hidden = true
        case .Connecting:
            outsideCircleView.backgroundColor = UIColor(red: 255.0 / 255.0 , green: 120.0 / 255.0 , blue: 27.0 / 255.0 , alpha: 0.60)
            connectedButton.hidden = true
            connectingButton.hidden = false
            disconnectedButton.hidden = true
            disconnectedButton.enabled = true
            cancelEmbededView.hidden = false
        case .Disconnected:
            outsideCircleView.backgroundColor = UIColor(red: 241.0 / 255.0 , green: 26.0 / 255.0 , blue: 53.0 / 255.0 , alpha: 0.60)
            connectedButton.hidden = true
            connectingButton.hidden = true
            disconnectedButton.hidden = false
            disconnectedButton.enabled = true
            cancelEmbededView.hidden = true
        case .Invalid, .Reasserting:
            outsideCircleView.backgroundColor = UIColor(red: 241.0 / 255.0 , green: 26.0 / 255.0 , blue: 53.0 / 255.0 , alpha: 0.60)
            connectedButton.hidden = true
            connectingButton.hidden = true
            disconnectedButton.hidden = false
            disconnectedButton.enabled = false
            cancelEmbededView.hidden = true
        case .Disconnecting:
            outsideCircleView.backgroundColor = UIColor(red: 241.0 / 255.0 , green: 26.0 / 255.0 , blue: 53.0 / 255.0 , alpha: 0.60)
            connectedButton.hidden = true
            connectingButton.hidden = true
            disconnectedButton.hidden = false
            disconnectedButton.enabled = false
            cancelEmbededView.hidden = true
        }
        
        connectionStateLabel.text = String(status)
    }
    
    func didChangeVPNStatus(notification: NSNotification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }

        let status = connection.status
        
        if status == .Connected {
            mainStore.dispatch(RegionAction.Connect)
        }
        
        updateViewWithVPNStatus(status)
    }

    @IBAction func connectAction(sender: UIButton) {
        if sender == self.disconnectedButton {
            do{
                try VPNConfigurationCoordinator.connect()
            }catch (let error) {
                print(error)
            }
        } else if sender == self.connectedButton {
            VPNConfigurationCoordinator.disconnect()
        }
    }

    @IBAction func cancelAction(sender: AnyObject) {
        VPNConfigurationCoordinator.disconnect()
    }
    
    func newState(state: AppState) {
        regionButton.setTitle(state.regionState.title, forState: .Normal)
    }

    @IBAction func transitionToConfigurationAction(sender: AnyObject) {
        let vc = R.storyboard.settings.settings()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func transitionToConnectionStatusAction(sender: AnyObject) {
        let vc = R.storyboard.settings.status()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
