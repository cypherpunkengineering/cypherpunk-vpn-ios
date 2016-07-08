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
