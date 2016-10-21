//
//  TwoColorGradientView.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/07.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

@IBDesignable class TwoColorGradientView: UIView {

    @IBInspectable var aColor: UIColor!
    @IBInspectable var bColor: UIColor!
    
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
    
        gradient.colors = [
            aColor.cgColor,
            bColor.cgColor
        ]
        
        self.layer.insertSublayer(gradient, at: 0)
        
        if self.gradientLayer != nil {
            self.gradientLayer.removeFromSuperlayer()
            self.gradientLayer = nil
        }

        self.gradientLayer = gradient
    }
    

}
