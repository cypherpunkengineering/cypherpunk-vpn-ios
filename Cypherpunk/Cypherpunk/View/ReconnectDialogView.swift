//
//  ReconnectDialogView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/12/13.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

private weak var __reconnectDialogView: ReconnectDialogView! = nil
class ReconnectDialogView: UIView {
    
    static func show() {
        
        if __reconnectDialogView == nil {
            let views = Bundle.main.loadNibNamed("ReconnectDialogView", owner: nil, options: nil)
            let retView = views?[0] as! UIView
            retView.frame = (UIApplication.shared.keyWindow?.frame)!
            __reconnectDialogView = views?[0] as! ReconnectDialogView
        }
        __reconnectDialogView.alpha = 0.0
        UIApplication.shared.keyWindow?.addSubview(__reconnectDialogView)
        UIView.animate(withDuration: 0.3, animations: {
            __reconnectDialogView.alpha = 1.0
        })
    }

    @IBAction func connectAction() {
        UIView.animate(withDuration: 0.3, animations: {  [unowned self] in
            self.alpha = 0.0
        }) { (finished) in
            VPNConfigurationCoordinator.connect()
            self.removeFromSuperview()
        }
    }
    
    @IBAction func cancelAction() {
        UIView.animate(withDuration: 0.3, animations: {  [unowned self] in
            self.alpha = 0.0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}
