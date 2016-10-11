//
//  ConnectionButtonsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

import ReSwift

class ConnectionButtonsViewController: UIViewController, StoreSubscriber {

    fileprivate var circleAnimationDuration: CFTimeInterval = 2

    @IBOutlet weak var connectedButton: UIButton!
    @IBOutlet weak var connectingButton: UIButton!
    @IBOutlet weak var disconnectedButton: UIButton!
    @IBOutlet weak var connectionStateLabel: UILabel!
    
    @IBOutlet weak var cancelEmbededView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var regionButton: UIButton!

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
        regionButton.setImage(UIImage(named: mainStore.state.regionState.countryCode), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        self.updateViewWithVPNStatus(status)
    }

    
    func updateViewWithVPNStatus(_ status: NEVPNStatus) {
        
        connectingButton.layer.removeAnimation(forKey: "rotation")
        cancelEmbededView.isHidden = true

        switch status {
        case .connected:
            connectedButton.isHidden = false
            connectingButton.isHidden = true
            disconnectedButton.isHidden = true
            disconnectedButton.isEnabled = true
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
        case .invalid:
            break
        case .disconnecting:
            connectedButton.isHidden = true
            connectingButton.isHidden = true
            disconnectedButton.isHidden = false
            disconnectedButton.isEnabled = false
        }
        
        connectionStateLabel.text = String(describing: status)
    }

    @IBAction func connectAction(_ sender: UIButton) {
        
        if TARGET_OS_SIMULATOR != 0 {
            mainStore.dispatch(RegionAction.connect)
            mainStore.dispatch(StatusAction.setConnectedDate(date: Date()))
            self.updateViewWithVPNStatus(.connected)
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
        }
        
        VPNConfigurationCoordinator.disconnect()
    }

    func newState(state: AppState) {
        regionButton.setTitle(state.regionState.title, for: .normal)
        regionButton.setImage(UIImage(named: state.regionState.countryCode)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
}
