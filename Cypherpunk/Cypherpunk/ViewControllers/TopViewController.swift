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
import APIKit

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connected: return "You are now protected"
        case .connecting: return "Connecting..."
        case .disconnected: return "Tap to protect"
        case .disconnecting: return "Disconnecting..."
        case .invalid: return "invalid"
        case .reasserting: return "reasserting"
        }
    }
}

class TopViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var connectedButton: UIButton!
    @IBOutlet weak var connectingButton: UIButton!
    @IBOutlet weak var disconnectedButton: UIButton!
    @IBOutlet weak var outsideCircleView: UIView!
    @IBOutlet weak var connectingBorderImageView: UIImageView!
    @IBOutlet weak var connectionStateLabel: UILabel!
    
    @IBOutlet weak var cancelEmbededView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var regionButton: UIButton!
    
    internal var connectionObserver: NSObjectProtocol!
    
    fileprivate var circleAnimationDuration: CFTimeInterval = 2
    @IBOutlet weak var getPremiumHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var getPremiumView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
    
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            NSForegroundColorAttributeName: UIColor.white
        ]
        let cancelAttributed = NSAttributedString(string: "Cancel", attributes: attributes)
        cancelButton.setAttributedTitle(cancelAttributed, for: UIControlState())
        regionButton.setTitle(mainStore.state.regionState.title, forState: .Normal)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true

        if mainStore.state.accountState.isLoggedIn == false {
            getPremiumHeightConstraint.constant = 50.0
            getPremiumView.isHidden = false
        } else {
            getPremiumHeightConstraint.constant = 0.0
            getPremiumView.isHidden = true
        }
        self.view.setNeedsLayout()
        
        VPNConfigurationCoordinator.load {
            let status = NEVPNManager.shared().connection.status
            self.updateViewWithVPNStatus(status)
        }
        
        mainStore.subscribe(self)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = M_PI * 2.0
        animation.duration = circleAnimationDuration
        animation.repeatCount = HUGE
        connectingBorderImageView.layer.add(animation, forKey: "rotation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainStore.unsubscribe(self)
        connectingBorderImageView.layer.removeAnimation(forKey: "rotation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    func updateViewWithVPNStatus(_ status: NEVPNStatus) {
        switch status {
        case .connected:
            outsideCircleView.backgroundColor = UIColor(red: 110.0 / 255.0 , green: 201.0 / 255.0 , blue: 9.0 / 255.0 , alpha: 0.60)
            connectedButton.isHidden = false
            connectingButton.isHidden = true
            disconnectedButton.isHidden = true
            disconnectedButton.isEnabled = true
            cancelEmbededView.isHidden = true
            connectingBorderImageView.isHidden = true
            outsideCircleView.isHidden = false
            
            let time = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC / 2)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: { 
                let IPRequest = JSONIPRequest()
                Session.sendRequest(IPRequest) {
                    (result) in
                    switch result {
                    case .Success(let response):
                        let IPAddress = response.IPAddress
                        if NEVPNManager.sharedManager().connection.status == .Connected {
                            mainStore.dispatch(StatusAction.GetNewIPAddress(address: IPAddress))
                            let request = GeoLocationRequest(IPAddress: IPAddress)
                            Session.sendRequest(request) {
                                (result) in
                                switch result {
                                case .Success(let response):
                                    if response.isSuccess {
                                        mainStore.dispatch(StatusAction.GetNewGeoLocation(response: response))
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    default:
                        break
                    }
                }    
            })
            
        case .connecting:
            outsideCircleView.backgroundColor = UIColor(red: 255.0 / 255.0 , green: 120.0 / 255.0 , blue: 27.0 / 255.0 , alpha: 0.60)
            connectedButton.isHidden = true
            connectingButton.isHidden = false
            disconnectedButton.isHidden = true
            disconnectedButton.isEnabled = true
            cancelEmbededView.isHidden = false
            connectingBorderImageView.isHidden = false
            outsideCircleView.isHidden = true
        case .disconnected:
            outsideCircleView.backgroundColor = UIColor(red: 241.0 / 255.0 , green: 26.0 / 255.0 , blue: 53.0 / 255.0 , alpha: 0.60)
            connectedButton.isHidden = true
            connectingButton.isHidden = true
            disconnectedButton.isHidden = false
            disconnectedButton.isEnabled = true
            cancelEmbededView.isHidden = true
            connectingBorderImageView.isHidden = true

            outsideCircleView.isHidden = false
            
            let IPRequest = JSONIPRequest()
            Session.sendRequest(IPRequest) {
                (result) in
                switch result {
                case .Success(let response):
                    let IPAddress = response.IPAddress
                    if NEVPNManager.sharedManager().connection.status == .Disconnected {
                        mainStore.dispatch(StatusAction.GetOriginalIPAddress(address: IPAddress))
                        let request = GeoLocationRequest(IPAddress: IPAddress)
                        Session.sendRequest(request) {
                            (result) in
                            switch result {
                            case .Success(let response):
                                if response.isSuccess {
                                    mainStore.dispatch(StatusAction.GetOriginalGeoLocation(response: response))
                                }
                            default:
                                break
                            }
                        }

                    }
                default:
                    break
                }
            }
            
        case .invalid, .reasserting:
            outsideCircleView.backgroundColor = UIColor(red: 241.0 / 255.0 , green: 26.0 / 255.0 , blue: 53.0 / 255.0 , alpha: 0.60)
            connectedButton.isHidden = true
            connectingButton.isHidden = true
            disconnectedButton.isHidden = false
            disconnectedButton.isEnabled = false
            cancelEmbededView.isHidden = true
            connectingBorderImageView.isHidden = true

            outsideCircleView.isHidden = false

        case .disconnecting:
            outsideCircleView.backgroundColor = UIColor(red: 241.0 / 255.0 , green: 26.0 / 255.0 , blue: 53.0 / 255.0 , alpha: 0.60)
            connectedButton.isHidden = true
            connectingButton.isHidden = true
            disconnectedButton.isHidden = false
            disconnectedButton.isEnabled = false
            cancelEmbededView.isHidden = true
            connectingBorderImageView.isHidden = true

            outsideCircleView.isHidden = false
        }

        connectionStateLabel.text = String(describing: status)
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }

        let status = connection.status
        
        if status == .connected {
            mainStore.dispatch(RegionAction.Connect)
            mainStore.dispatch(StatusAction.SetConnectedDate(date: Date()))
        } else if status == .disconnected {
            mainStore.dispatch(StatusAction.SetConnectedDate(date: nil))
        }

        self.updateViewWithVPNStatus(status)
    }

    @IBAction func connectAction(_ sender: UIButton) {
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

    @IBAction func cancelAction(_ sender: AnyObject) {
        VPNConfigurationCoordinator.disconnect()
    }
    
    func newState(_ state: AppState) {
        regionButton.setTitle(state.regionState.title, for: UIControlState())
    }

    @IBAction func transitionToConfigurationAction(_ sender: AnyObject) {
        let vc = R.storyboard.configuration.configuration()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func transitionToConnectionStatusAction(_ sender: AnyObject) {
        let vc = R.storyboard.configuration.connectionStatus()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
