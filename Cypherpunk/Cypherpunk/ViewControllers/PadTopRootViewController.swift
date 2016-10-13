//
//  PadTopRootViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

class PadTopRootViewController: UIViewController {

    @IBOutlet weak var installPreferencesView: UIView!
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var connectionActionView: UIView!
    @IBOutlet weak var locationActionView: UIView!
    @IBOutlet weak var contentsSeparatorView: UIView!

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
        
        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateView(withVPNStatus: status)
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
        if status == .invalid {
            installPreferencesView.isHidden = false
            connectionActionView.isHidden = true
            locationActionView.isHidden = true
            animationContainerView.isHidden = true
            contentsSeparatorView.isHidden = true
        } else {
            installPreferencesView.isHidden = true
            connectionActionView.isHidden = false
            locationActionView.isHidden = false
            animationContainerView.isHidden = false
            contentsSeparatorView.isHidden = false
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
