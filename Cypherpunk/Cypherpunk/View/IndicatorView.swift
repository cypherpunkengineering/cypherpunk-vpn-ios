//
//  IndicatorView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/09/09.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import QuartzCore
private weak var __indicatorView: IndicatorView! = nil
class IndicatorView: UIView {
    
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    static func show() {
        
        if __indicatorView == nil {
                let views = Bundle.main.loadNibNamed("BlurredIndicatorView", owner: nil, options: nil)
                let retView = views?[0] as! UIView
                retView.frame = (UIApplication.shared.keyWindow?.frame)!
                __indicatorView = views?[0] as! IndicatorView
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            UIApplication.shared.keyWindow?.addSubview(__indicatorView)
            }, completion: { (finished) in
                if finished {
                    __indicatorView.startAnimation()
                }
        })
    }
    
    static func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            __indicatorView.removeFromSuperview()
        })
    }
    
    fileprivate func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = M_PI * 2
        animation.duration = 2
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        
        indicatorImageView.layer.add(animation, forKey: "rorationAnimation")
    }
    
    fileprivate func stopAnimation() {
        indicatorImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
}
