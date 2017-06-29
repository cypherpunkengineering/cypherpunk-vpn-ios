//
//  AccountButton.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 5/24/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class AccountButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.aztec
        self.setImage(R.image.account_icon(), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // mask to round the corners
        let halfHeight = self.bounds.height / 2
        
        let maskPath = UIBezierPath()
        maskPath.move(to: CGPoint(x: 0, y: self.bounds.height))
        maskPath.addLine(to: CGPoint(x: self.bounds.width - halfHeight, y: self.bounds.height))
        maskPath.addArc(withCenter: CGPoint(x: self.bounds.width - halfHeight, y: halfHeight), radius: halfHeight, startAngle: CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: false)
        maskPath.addLine(to: CGPoint(x: 0, y: 0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        
        
        // path for the outline
        let outlinePath = UIBezierPath()
        outlinePath.move(to: CGPoint(x: 0, y: self.bounds.height))
        outlinePath.addLine(to: CGPoint(x: self.bounds.width - halfHeight, y: self.bounds.height))
        
        outlinePath.addArc(withCenter: CGPoint(x: self.bounds.width - halfHeight, y: halfHeight), radius: halfHeight, startAngle: CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: false)

        outlinePath.lineWidth = 3

        UIColor.greenVogue.set()
        
        outlinePath.stroke()
    }

}
