//
//  MainViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 5/24/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import Cartography
import simd
import RealmSwift
import NetworkExtension
import ReSwift
import TinySwift

class MainViewController: UIViewController, StoreSubscriber, VPNSwitchDelegate, LocationSelectionDelegate {
    
    var topBarView: UIView
    var bottomBorderLayer: CALayer
    var mapImageView: MapImageView
    var vpnSwitch: VPNSwitch
    var locationSelectorButton: UIButton
    var locationSelectorVC: LocationSelectorViewController?
    
    required init?(coder aDecoder: NSCoder) {
        self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 70.0))
        self.topBarView.backgroundColor = UIColor.aztec
        
        self.bottomBorderLayer = CALayer()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: 0, width: 200.0, height: 1)
        self.bottomBorderLayer.backgroundColor = UIColor.greenVogue.cgColor
        self.topBarView.layer.addSublayer(self.bottomBorderLayer)
        
        self.mapImageView = MapImageView()
        
        self.vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        self.locationSelectorButton = UIButton(type: .custom)
        self.locationSelectorButton.titleLabel?.text = "Location"
        self.locationSelectorButton.frame = CGRect(x: 0, y: 0, width: 175, height: 60)
        self.locationSelectorButton.backgroundColor = UIColor.green
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // listen for VPN status changes
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(vpnStatusChanged(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        
        
        // Add gradient layer for gradient background color
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor(hex: "#0F2125")!.cgColor, UIColor(hex: "#004444")!.cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)

        // add map image view
        self.view.addSubview(self.mapImageView)
        
        self.view.addSubview(self.topBarView)
        constrain(self.view, self.topBarView) { parentView, childView in
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
            childView.top == parentView.top
            childView.height == 64.0
        }
        
        let logoImageView = UIImageView(image: R.image.headerIconLogo())
        self.topBarView.addSubview(logoImageView)
        constrain(self.topBarView, logoImageView) { parentView, childView in
            childView.centerX == parentView.centerX
            childView.top == parentView.top + 32
        }
        
        let leftButton = AccountButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        leftButton.addTarget(self, action: #selector(openOrCloseAccountAction(_:)), for: .touchUpInside)
        self.view.addSubview(leftButton)
        constrain(self.view, leftButton) { parentView, childView in
            childView.leading == parentView.leading
            childView.top == parentView.top + 36.0
            childView.height == 60.0
            childView.width == 60.0
        }
        
        let rightButton = ConfigurationButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        rightButton.addTarget(self, action: #selector(openOrCloseConfigurationAction(_:)), for: .touchUpInside)
        self.view.addSubview(rightButton)
        constrain(self.view, rightButton) { parentView, childView in
            childView.trailing == parentView.trailing
            childView.top == parentView.top + 36.0
            childView.height == 60.0
            childView.width == 60.0
        }
        
        self.view.addSubview(self.vpnSwitch)
        constrain(self.view, self.vpnSwitch, self.topBarView) { parentView, childView, topBarView in
            childView.top == topBarView.bottom + 100
            childView.height == 50.0
            childView.width == 100.0
            childView.centerX == parentView.centerX
        }
        self.vpnSwitch.delegate = self
        
        self.view.addSubview(self.locationSelectorButton)
        constrain(self.view, self.locationSelectorButton, self.vpnSwitch) { parentView, childView, vpnSwitch in
            childView.top == vpnSwitch.bottom + 100
            childView.height == 60.0
            childView.width == 175.0
            childView.centerX == parentView.centerX
        }
        self.locationSelectorButton.addTarget(self, action: #selector(showLocationSelector(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateView(vpnStatus: status)
        }
        
        mainStore.subscribe(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: self.topBarView.frame.height - 1, width: self.topBarView.frame.width, height: 1)
    }
    

    @IBAction func openOrCloseConfigurationAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: kOpenOrCloseConfigurationNotification, object: nil)
    }
    @IBAction func openOrCloseAccountAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: kOpenOrCloseAccountNotification, object: nil)
    }
    
    @IBAction func showLocationSelector(_ sender: AnyObject) {
        self.locationSelectorVC = LocationSelectorViewController(nibName: "LocationSelectorViewController", bundle: nil)
        self.locationSelectorVC?.delegate = self
        
        self.addChildViewController(self.locationSelectorVC!)
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            self.view.addSubview((self.locationSelectorVC?.view)!)
            self.locationSelectorVC?.didMove(toParentViewController: self)
            constrain(self.view, (self.locationSelectorVC?.view)!, self.topBarView) { parentView, childView, topBarView in
                childView.top == topBarView.bottom
                childView.leading == parentView.leading
                childView.trailing == parentView.trailing
                childView.bottom == parentView.bottom
            }
        }, completion: nil)
    }
    
    private func updateView(vpnStatus: NEVPNStatus) {
        if UIDevice.current.isSimulator {
            // TODO what should be done here
        }
        else {
            switch vpnStatus {
            case .invalid:
                print("INVALID") // TODO
                break
            case .connected:
//                vpnSwitch.isOn = true
                break
            case .disconnected:
//                vpnSwitch.isOn = false
                break
            default:
                break
            }
        }
    }
    
    func vpnStatusChanged(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        switch status {
        case .invalid:
            print("INVALID") // TODO
            break
        case .connected:
            vpnSwitch.isOn = true
        case .disconnected:
            vpnSwitch.isOn = false
        default:
            break
        }
        
        self.updateView(vpnStatus: status)
    }
    
    func newState(state: AppState) {
//        regionTitleLabel?.text = state.regionState.title
//        regionFlagImageView?.image = UIImage(named: state.regionState.countryCode.lowercased())?.withRenderingMode(.alwaysOriginal)
//        premiumLocationIconWidthConstraint?.constant = 0.0
//        devLocationIconWidthConstraint?.constant = 0.0
//        regionTrailingConstraint?.constant = 0.0
//        premiumLocationIconView?.isHidden = true
//        devLocationIconView?.isHidden = true
//        if state.regionState.level == "premium" {
//            premiumLocationIconWidthConstraint?.constant = 56.0
//            devLocationIconWidthConstraint?.constant = 56.0
//            regionTrailingConstraint?.constant = 32.0
//            premiumLocationIconView?.isHidden = false
//        } else if state.regionState.level == "developer" {
//            premiumLocationIconWidthConstraint?.constant = 25.0
//            devLocationIconWidthConstraint?.constant = 25.0
//            devLocationIconView?.isHidden = false
//        }
//        self.view.layoutIfNeeded()
    }
    
    // MARK: - VPNSwitchDelegate
    func stateChanged(on: Bool) {
        if UIDevice.current.isSimulator {
            mainStore.dispatch(RegionAction.connect)
            self.updateView(vpnStatus: .connected)
        }
        else {
            if on {
                VPNConfigurationCoordinator.connect()
            }
            else {
                VPNConfigurationCoordinator.disconnect()
            }
        }
    }
    
    // MARK: - LocationSelectionDelegate
    func dismissSelector() {
        self.locationSelectorVC?.willMove(toParentViewController: nil)
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: { 
            self.locationSelectorVC?.view.removeFromSuperview()
        }) { (completed) in
            self.locationSelectorVC?.removeFromParentViewController()
        }
    }
}
