//
//  ShadowView.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/11/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    @IBInspectable var leftAlpha: CGFloat = 0.0
    @IBInspectable var rightAlpha: CGFloat = 0.0
    
    var gradientLayer: CAGradientLayer! = nil
    override var bounds: CGRect {
        didSet {
            if self.gradientLayer != nil {
                self.gradientLayer.removeFromSuperlayer()
                self.gradientLayer = nil
            }
            
            self.setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        didSet {
            if self.gradientLayer != nil {
                self.gradientLayer.removeFromSuperlayer()
                self.gradientLayer = nil
            }
            
            self.setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        gradient.colors = [
            UIColor.black.withAlphaComponent(leftAlpha).cgColor,
            UIColor.black.withAlphaComponent(rightAlpha).cgColor,
        ]
        
        self.layer.insertSublayer(gradient, at: 0)
        
        if self.gradientLayer != nil {
            self.gradientLayer.removeFromSuperlayer()
            self.gradientLayer = nil
        }
        
        self.gradientLayer = gradient
    }
}
