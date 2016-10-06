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
import MZFormSheetPresentationController

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
    @IBOutlet weak var connectionStateLabel: UILabel!
    
    @IBOutlet weak var cancelEmbededView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var regionButton: UIButton!
    @IBOutlet weak var configurationButton: UIButton!
    @IBOutlet weak var connectionStatusButton: UIButton!
    
    @IBOutlet weak var installPreferencesView: UIView!
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var connectionActionView: UIView!
    @IBOutlet weak var regionButtonView: UIView!
    
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
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            NSForegroundColorAttributeName: UIColor.white
        ]
        let cancelAttributed = NSAttributedString(string: "Cancel", attributes: attributes)
        cancelButton.setAttributedTitle(cancelAttributed, for: .normal)
        regionButton.setTitle(mainStore.state.regionState.title, for: .normal)
        

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
        
        VPNConfigurationCoordinator.load {_ in 
            let status = NEVPNManager.shared().connection.status
            self.updateViewWithVPNStatus(status)
        }
        
        mainStore.subscribe(self, selector: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    private weak var animationController: AnimationViewController!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vcs = self.childViewControllers.filter { (vc) -> Bool in
            if vc is AnimationViewController {
                return true
            }
            return false
        }
        
        if vcs.count > 0 {
            animationController = vcs[0] as! AnimationViewController
        }
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
        
        animationContainerView.isHidden = false
        connectionActionView.isHidden = false
        regionButtonView.isHidden = false
        connectionStatusButton.isHidden = false
        configurationButton.isHidden = false
        installPreferencesView.isHidden = true
        connectingButton.layer.removeAnimation(forKey: "rotation")

        switch status {
        case .connected:
            connectedButton.isHidden = false
            connectingButton.isHidden = true
            disconnectedButton.isHidden = true
            disconnectedButton.isEnabled = true
            cancelEmbededView.isHidden = true
            
            let time = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: { 
                let IPRequest = JSONIPRequest()
                Session.send(IPRequest) {
                    (result) in
                    switch result {
                    case .success(let response):
                        let IPAddress = response.IPAddress
                        if NEVPNManager.shared().connection.status == .connected {
                            mainStore.dispatch(StatusAction.getNewIPAddress(address: IPAddress))
                            let request = GeoLocationRequest(IPAddress: IPAddress)
                            Session.send(request) {
                                (result) in
                                switch result {
                                case .success(let response):
                                    if response.isSuccess {
                                        mainStore.dispatch(StatusAction.getNewGeoLocation(response: response))
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
            
        case .connecting, .reasserting:
            
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = M_PI * 2.0
            animation.duration = circleAnimationDuration
            animation.repeatCount = HUGE
            connectingButton.layer.add(animation, forKey: "rotation")

            connectedButton.isHidden = true
            connectingButton.isHidden = false
            disconnectedButton.isHidden = true
            disconnectedButton.isEnabled = true
            cancelEmbededView.isHidden = false
        case .disconnected:
            connectedButton.isHidden = true
            connectingButton.isHidden = true
            disconnectedButton.isHidden = false
            disconnectedButton.isEnabled = true
            cancelEmbededView.isHidden = true
            
            let IPRequest = JSONIPRequest()
            Session.send(IPRequest) {
                (result) in
                switch result {
                case .success(let response):
                    let IPAddress = response.IPAddress
                    if NEVPNManager.shared().connection.status == .disconnected {
                        mainStore.dispatch(StatusAction.getOriginalIPAddress(address: IPAddress))
                        let request = GeoLocationRequest(IPAddress: IPAddress)
                        Session.send(request) {
                            (result) in
                            switch result {
                            case .success(let response):
                                if response.isSuccess {
                                    mainStore.dispatch(StatusAction.getOriginalGeoLocation(response: response))
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
            
        case .invalid:
            if TARGET_OS_SIMULATOR == 0 {
                animationContainerView.isHidden = true
                connectionActionView.isHidden = true
                regionButtonView.isHidden = true
                connectionStatusButton.isHidden = true
                configurationButton.isHidden = true
                installPreferencesView.isHidden = false
            }
        case .disconnecting:
            connectedButton.isHidden = true
            connectingButton.isHidden = true
            disconnectedButton.isHidden = false
            disconnectedButton.isEnabled = false
            cancelEmbededView.isHidden = true
        }

        connectionStateLabel.text = String(describing: status)
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateViewWithVPNStatus(status)
        }
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }

        let status = connection.status
        
        if status == .connected {
            mainStore.dispatch(RegionAction.connect)
            mainStore.dispatch(StatusAction.setConnectedDate(date: Date()))
        } else if status == .disconnected {
            mainStore.dispatch(StatusAction.setConnectedDate(date: nil))
        }

        self.updateViewWithVPNStatus(status)
    }

    @IBAction func connectAction(_ sender: UIButton) {
        
        if TARGET_OS_SIMULATOR != 0 {
            mainStore.dispatch(RegionAction.connect)
            mainStore.dispatch(StatusAction.setConnectedDate(date: Date()))
            self.updateViewWithVPNStatus(.connected)
            self.animationController.updateAnimationState(status: .connected)
        } else {
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
    }

    @IBAction func cancelAction(_ sender: AnyObject) {
        if TARGET_OS_SIMULATOR != 0 {
            mainStore.dispatch(StatusAction.setConnectedDate(date: nil))
            self.updateViewWithVPNStatus(.disconnected)
            self.animationController.updateAnimationState(status: .disconnected)
        }

        VPNConfigurationCoordinator.disconnect()
    }
    
    func newState(state: AppState) {
        regionButton.setTitle(state.regionState.title, for: .normal)
    }

    var isFirst: Bool = false
    func showRateAppScreen() {
        if isFirst == false {
            let content = R.storyboard.rateApp.instantiateInitialViewController()
            let formSheet = MZFormSheetPresentationViewController(contentViewController: content!)
            formSheet.presentationController?.contentViewSize = CGSize(width: 296.0, height: 341.0)
            formSheet.presentationController?.isTransparentTouchEnabled = false
            formSheet.presentationController?.shouldCenterVertically = true
            formSheet.presentationController?.shouldCenterHorizontally = true
            self.present(formSheet, animated: true, completion: nil)

            isFirst = true
        }
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
