//
//  PadTopRootViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

import ReSwift

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

class PadTopRootViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var connectionActionView: UIView!
    @IBOutlet weak var locationActionView: UIView!
    @IBOutlet weak var contentsSeparatorView: UIView?
    
    @IBOutlet weak var regionButton: UIButton?
    @IBOutlet weak var expandArrowImageView: UIImageView?
    
    @IBOutlet weak var devLocationIconView: UIImageView?
    @IBOutlet weak var premiumLocationIconView: UIImageView?
    
    @IBOutlet weak var regionTrailingConstraint: NSLayoutConstraint?
    @IBOutlet weak var regionTitleLabel: UILabel?
    @IBOutlet weak var regionFlagImageView: UIImageView?
    @IBOutlet weak var devLocationIconWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var premiumLocationIconWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var connectionButtonsConstraint: NSLayoutConstraint?
    var isExpand: Bool = false
    
    @IBOutlet weak var buttonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let logoView = UIImageView(image: R.image.headerIconLogo())
        self.navigationItem.titleView = logoView
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: R.font.dosisSemiBold(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.white,
        ]

        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
                
        if let state = mainStore.state {
            regionButton?.setTitle(state.regionState.title, for: .normal)
            regionButton?.setImage(UIImage(named: state.regionState.countryCode.lowercased())?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        self.connectionButtonsConstraint?.constant = CGFloat(ButtonGridHelper.heightForButtonGrid())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateView(withVPNStatus: status)
        }
        
        if isExpand {
            let angle = -M_PI_2
            expandArrowImageView?.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
        } else {
            let angle = M_PI_2
            expandArrowImageView?.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
        }
        
        mainStore.subscribe(self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainStore.unsubscribe(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        updateView(withVPNStatus: status)
    }
    
    func updateView(withVPNStatus status: NEVPNStatus) {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            if status == .invalid {
                if TARGET_OS_SIMULATOR == 0 {
                    connectionActionView.isHidden = true
                    locationActionView.isHidden = true
                    animationContainerView.isHidden = true
                    contentsSeparatorView?.isHidden = true
                }
            } else {
                connectionActionView.isHidden = false
                locationActionView.isHidden = false
                animationContainerView.isHidden = false
                contentsSeparatorView?.isHidden = false
            }
        } else {
            connectionActionView.isHidden = false
            locationActionView.isHidden = false
            animationContainerView.isHidden = false
            contentsSeparatorView?.isHidden = false
        }
    }
    
    func newState(state: AppState) {
        regionButton?.setTitle(state.regionState.title, for: .normal)
        regionTitleLabel?.text = state.regionState.title
        regionFlagImageView?.image = UIImage(named: state.regionState.countryCode.lowercased())?.withRenderingMode(.alwaysOriginal)
        premiumLocationIconWidthConstraint?.constant = 0.0
        devLocationIconWidthConstraint?.constant = 0.0
        regionTrailingConstraint?.constant = 0.0
        premiumLocationIconView?.isHidden = true
        devLocationIconView?.isHidden = true
        if state.regionState.level == "premium" {
            premiumLocationIconWidthConstraint?.constant = 56.0
            devLocationIconWidthConstraint?.constant = 56.0
            regionTrailingConstraint?.constant = 32.0
            premiumLocationIconView?.isHidden = false
        } else if state.regionState.level == "developer" {
            premiumLocationIconWidthConstraint?.constant = 25.0
            devLocationIconWidthConstraint?.constant = 25.0
            devLocationIconView?.isHidden = false
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func openOrCloseConfigurationAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: kOpenOrCloseConfigurationNotification, object: nil)
    }
    @IBAction func openOrCloseAccountAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: kOpenOrCloseAccountNotification, object: nil)
    }
    
    @IBAction func openOrCloseRegionAction(_ sender: AnyObject) {
        let angle: Double
        if connectionButtonsConstraint?.constant == 260.0 {
            connectionButtonsConstraint?.constant = 0.0
            isExpand = false
            angle = M_PI_2 + M_PI
            expandArrowImageView?.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
        } else {
            connectionButtonsConstraint?.constant = 260.0
            angle = M_PI_2

            isExpand = true
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.expandArrowImageView?.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
            }, completion: nil)
    }
    
}
