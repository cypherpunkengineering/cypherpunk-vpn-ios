//
//  ThemedStatusBarBackgroundView.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedStatusBarBackgroundView: UIView {
    
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        self.isHidden = false
        
        DispatchQueue.main.async(execute: {
            
            let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
            let bottomColor = UIColor(red: 112 / 255.0, green: 164 / 255.0 , blue: 231 / 255.0 , alpha: 1.0)
            let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
            
            let gradientLayer: CAGradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors
            gradientLayer.frame = self.layer.frame
            
            self.layer.insertSublayer(gradientLayer, at: 0)
        })
        
    }
    
}
