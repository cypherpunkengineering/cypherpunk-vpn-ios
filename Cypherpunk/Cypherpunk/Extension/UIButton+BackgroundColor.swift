//
//  UIButton+BackgroundColor.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 5/23/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.width, height: self.bounds.height))
        
        let cgContext =  UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRadius).cgPath
        
        cgContext.addPath(clipPath)
        cgContext.closePath()
        
        cgContext.setFillColor(color.cgColor)
        cgContext.fillPath()
        
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}

