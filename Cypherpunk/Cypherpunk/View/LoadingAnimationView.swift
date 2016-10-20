//
//  LoadingAnimationView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import QuartzCore

class LoadingAnimationView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startAnimation()
    }
    
    override open var image: UIImage? {
        get {
            return R.image.loading()
        }
        set {
            
        }
    }
    
    func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = M_PI * 2
        animation.duration = 2
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        
        self.layer.add(animation, forKey: "rorationAnimation")
    }
    
    func stopAnimation() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
}
