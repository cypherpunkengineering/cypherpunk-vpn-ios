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
                let views = NSBundle.mainBundle().loadNibNamed("BlurredIndicatorView", owner: nil, options: nil)
                let retView = views[0] as! UIView
                retView.frame = (UIApplication.sharedApplication().keyWindow?.frame)!
                __indicatorView = views[0] as! IndicatorView
        }
        
        UIView.animateWithDuration(0.3, animations: {
            UIApplication.sharedApplication().keyWindow?.addSubview(__indicatorView)
            }, completion: { (finished) in
                if finished {
                    __indicatorView.startAnimation()
                }
        })
    }
    
    static func dismiss() {
        UIView.animateWithDuration(0.3, animations: {
            __indicatorView.removeFromSuperview()
        })
    }
    
    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = M_PI * 2
        animation.duration = 2
        animation.cumulative = true
        animation.repeatCount = Float.infinity
        
        indicatorImageView.layer.addAnimation(animation, forKey: "rorationAnimation")
    }
    
    private func stopAnimation() {
        indicatorImageView.layer.removeAnimationForKey("rotationAnimation")
    }
    
}
