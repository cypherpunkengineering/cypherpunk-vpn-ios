//
//  TwoColorGradientButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

@IBDesignable class TwoColorGradientButton: UIButton {
    
    @IBInspectable var aColor: UIColor!
    @IBInspectable var bColor: UIColor!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        
        gradient.colors = [
            aColor.CGColor,
            bColor.CGColor
        ]
        
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    
}
