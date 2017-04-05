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

class PadTopRootViewController: UIViewController, StoreSubscriber, RegionSelectionDelegate, ButtonsDelegate {
    
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
    @IBOutlet weak var serverListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var serverListView: UIView!
    var isExpand: Bool = false
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var tabletButtonsHeightConstraint: NSLayoutConstraint?
    
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
        
        self.connectionButtonsConstraint?.constant = CGFloat(heightForButtonGrid())
        
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            loadButtonViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateView(withVPNStatus: status)
        }
                
        mainStore.subscribe(self)
        
        updateTabletButtonsHeight(animate: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainStore.unsubscribe(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateTabletButtonsHeight(animate: true)
    }
    
    private func updateTabletButtonsHeight(animate: Bool) {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.tabletButtonsHeightConstraint?.constant = UIDevice.current.orientation.isLandscape ? 140 : 190
            
            if animate {
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
            }
            else {
                self.view.layoutIfNeeded()
            }
        }
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
                if UIDevice.current.isSimulator {
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
        if (isExpand) {
            // already expanded, collapse
            isExpand = false
            
            UIView.animate(withDuration: 0.5) {
                self.serverListHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else {
            isExpand = true
            
            UIView.animate(withDuration: 0.5) {
                let visibleSize = self.getVisibleSize()
                self.serverListHeightConstraint.constant = visibleSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EmbedRegionList") {
            let regionSelectViewController = segue.destination as! RegionSelectViewController
            
            regionSelectViewController.delegate = self
        }
    }
    
    func getVisibleSize() -> CGSize {
        var result = CGSize();
        
        var size = UIScreen.main.bounds.size
        
        if (UIDevice.current.orientation.isLandscape) {
            result.width = size.height
            result.height = size.width
        }
        else {
            result.width = size.width
            result.height = size.height
        }
        
        size = UIApplication.shared.statusBarFrame.size
        result.height -= min(size.width, size.height)
        
        if (self.navigationController != nil) {
            size = (self.navigationController?.navigationBar.frame.size)!
            result.height -= min(size.width, size.height)
        }
        
        return result
    }
    
    private func loadButtonViewController() {
        var buttonViewController: BaseButtonsViewController?
        
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            buttonViewController = ThreeButtonViewController(nibName: "ThreeButtonViewController", bundle: Bundle.main)
        }
        else if (UIScreen.main.bounds.height < 667) {
            buttonViewController = FiveButtonViewController(nibName: "FiveButtonViewController", bundle: Bundle.main)
        }
        else {
            // iPhone 6 and above
            buttonViewController = SevenButtonViewController(nibName: "SevenButtonViewController", bundle: Bundle.main)
        }
        
        self.addChildViewController(buttonViewController!)
        buttonViewController?.view.frame = CGRect(x: 0, y: 0, width: buttonView.frame.width, height: buttonView.frame.height)
        
        self.buttonView.addSubview((buttonViewController?.view)!)
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: buttonViewController?.view as Any, attribute: .leading, relatedBy: .equal, toItem: buttonView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: buttonViewController?.view! as Any, attribute: .trailing, relatedBy: .equal, toItem: buttonView, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: buttonViewController?.view! as Any, attribute: .top, relatedBy: .equal, toItem: buttonView, attribute: .topMargin, multiplier: 1.0, constant:0.0).isActive = true
        
        NSLayoutConstraint(item: buttonViewController?.view! as Any, attribute: .bottom, relatedBy: .equal, toItem: buttonView, attribute: .bottomMargin, multiplier: 1.0, constant:0.0).isActive = true
        
        buttonView.layoutIfNeeded()
        
        buttonViewController?.didMove(toParentViewController: self)
        
        buttonViewController?.delegate = self
    }
    
    func heightForButtonGrid() -> Int {
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            return 100
        }
        else {
            return 200
        }
    }
    
    // MARK: RegionSelectionDelegate
    func dismissRegionSelector() {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            openOrCloseRegionAction(self)
        }
    }
    
    // MARK: MainButtonsDelegate
    func showServerList() {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            openOrCloseRegionAction(self)            
        }
    }
}
