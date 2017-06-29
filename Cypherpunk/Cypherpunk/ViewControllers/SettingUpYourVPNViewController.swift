//
//  SettingUpYourVPNViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

class SettingUpYourVPNViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(
//            self,
//            selector: #selector(didChangeVPNStatus),
//            name: NSNotification.Name.NEVPNStatusDidChange,
//            object: nil
//        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if mainStore.state.isInstalledPreferences {
            NotificationCenter.default.removeObserver(self)
            performSegue(withIdentifier: "showAnalyticsStep", sender: nil)
        }
        
        let connection = NEVPNManager.shared().connection
        let status = connection.status
        if status != .invalid {
            // 次のページ
            showAnalyticsStep()
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func didChangeVPNStatus(_ notification: Notification) {
//        guard let connection = notification.object as? NEVPNConnection else {
//            return
//        }
//        
//        let status = connection.status
//        if status != .invalid {
//            // 次のページ
//            showAnalyticsStep()
//        }
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func allowAction(_ sender: AnyObject) {
        if UIDevice.current.isSimulator {
            mainStore.dispatch(AppAction.VPNInstalled)
            NotificationCenter.default.removeObserver(self)
            performSegue(withIdentifier: "showAnalyticsStep", sender: nil)
        } else {
            VPNConfigurationCoordinator.install() { (error) in
                if error == nil {
                    self.showAnalyticsStep()
                }
            }
        }
    }
    
    private func showAnalyticsStep() {
        mainStore.dispatch(AppAction.VPNInstalled)
        NotificationCenter.default.removeObserver(self)
        performSegue(withIdentifier: "showAnalyticsStep", sender: nil)
    }
}
