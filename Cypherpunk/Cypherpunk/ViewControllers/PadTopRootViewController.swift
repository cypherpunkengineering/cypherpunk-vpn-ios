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

class PadTopRootViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var installPreferencesView: UIView?
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var connectionActionView: UIView!
    @IBOutlet weak var locationActionView: UIView!
    @IBOutlet weak var contentsSeparatorView: UIView?

    @IBOutlet weak var regionButton: UIButton?
    @IBOutlet weak var expandArrowImageView: UIImageView!
    
    var isExpand: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let logoView = UIImageView(image: R.image.headerLogo())
        self.navigationItem.titleView = logoView
        
        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateView(withVPNStatus: status)
        }
        
        if isExpand {
            let angle = M_PI_2
            expandArrowImageView.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
        } else {
            let angle = -M_PI_2
            expandArrowImageView.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
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
        if status == .invalid {
            if TARGET_OS_SIMULATOR == 0 {
                installPreferencesView?.isHidden = false
                connectionActionView.isHidden = true
                locationActionView.isHidden = true
                animationContainerView.isHidden = true
                contentsSeparatorView?.isHidden = true
            }
        } else {
            installPreferencesView?.isHidden = true
            connectionActionView.isHidden = false
            locationActionView.isHidden = false
            animationContainerView.isHidden = false
            contentsSeparatorView?.isHidden = false
        }
    }

    func newState(state: AppState) {
        regionButton?.setTitle(state.regionState.title, for: .normal)
        regionButton?.setImage(UIImage(named: state.regionState.countryCode)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    @IBAction func transitionToConfigurationAction(_ sender: AnyObject) {
        let vc = R.storyboard.configuration.configuration()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func transitionToAccountAction(_ sender: AnyObject) {
        let vc = R.storyboard.top_iPad.account()
        self.navigationController?.pushViewController(vc!, animated: true)
    }


}
