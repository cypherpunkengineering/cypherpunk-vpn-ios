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

class MainViewController: UIViewController, StoreSubscriber, VPNSwitchDelegate {
    
    var topBarView: UIView
    var bottomBorderLayer: CALayer
    var mapImageView: MapImageView
    var vpnSwitch: VPNSwitch
    
    required init?(coder aDecoder: NSCoder) {
        self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 70.0))
        self.topBarView.backgroundColor = UIColor.aztec
        
        self.bottomBorderLayer = CALayer()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: 0, width: 200.0, height: 1)
        self.bottomBorderLayer.backgroundColor = UIColor.greenVogue.cgColor
        self.topBarView.layer.addSublayer(self.bottomBorderLayer)
        
        self.mapImageView = MapImageView()
        
        self.vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
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
        gradient.colors = [UIColor(hexString: "#0F2125").cgColor, UIColor(hexString: "#004444").cgColor]
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
    
    // MARK: - Map Helpers
    let mapSize = 1000.0 // width, image is 2000 pixels but in points it will be 1000
    let longOffset: Double = 11
    let pi = Double.pi
    let halfPi = Double.pi / 2
    let epsilon = Double.ulpOfOne
    
    // accepts radians
    private func vanDerGrinten3Raw(lambda: Double, phi: Double) -> (x: Double, y: Double) {
        if (abs(phi) < epsilon) {
            return (x: lambda, y: 0)
        }
        
        let sinTheta = phi / halfPi
        let theta = asin(sinTheta)
        
        if (abs(lambda) < epsilon || abs(abs(phi) - halfPi) < epsilon) {
            return (x: 0, y: tan(theta / 2))
        }
        
        let A = (pi / lambda - lambda / pi) / 2
        let y1 = sinTheta / (1 + cos(theta))
        
        return (x: pi * (sign(lambda) * sqrt(A * A + 1 - y1 * y1) - A), y: pi * y1)
    }
    
    // GPS coordinates in degrees
    func transformToXY(lat: Double, long: Double) -> (x: Double, y: Double) {
        let coords = vanDerGrinten3Raw(lambda: (long - longOffset) * pi / 180, phi: lat * pi / 180)
        
        let temp: Double = mapSize / 920.0
        let xCoord = (coords.x * 150.0 + (920 / 2)) * temp
        let yCoord = (coords.y * 150 + (500 / 2 + 500 * 0.15)) * temp
        
        return (x: xCoord, y: yCoord)
    }
    
    func drawLocationOnMap(lat: Double, long: Double) {
        let imageCoordinates = transformToXY(lat: lat, long: long)
        print(imageCoordinates)
        let dotPath = UIBezierPath(ovalIn: CGRect(x: imageCoordinates.x, y: imageCoordinates.y, width: 5, height: 5))
        
        let layer = CAShapeLayer()
//        layer.bounds = self.mapImageView.bounds
        layer.path = dotPath.cgPath
        layer.fillColor = UIColor.white.cgColor
        
        self.mapImageView.layer.addSublayer(layer)
    }

}
