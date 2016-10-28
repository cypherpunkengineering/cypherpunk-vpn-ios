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

        if mainStore.state.isInstalledPreferences {
            let notification = Notification(name: ScrollToSecondPage)
            NotificationCenter.default.post(notification)
            NotificationCenter.default.removeObserver(self)
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
        if status != .invalid {
            // 次のページ
            mainStore.dispatch(AppAction.VPNInstalled)
            let notification = Notification(name: ScrollToSecondPage)
            NotificationCenter.default.post(notification)
            NotificationCenter.default.removeObserver(self)
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

    @IBAction func allowAction(_ sender: AnyObject) {
        VPNConfigurationCoordinator.install()
    }
}
