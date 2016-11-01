//
//  ThemedBackgroundView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedBackgroundView: UIView {
    
    var gradientLayer: CAGradientLayer! = nil
    override var frame: CGRect {
        didSet {
            DispatchQueue.main.async(execute: {
                let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
                let bottomColor = UIColor(red: 3.0 / 255.0, green: 70.0 / 255.0 , blue: 152.0 / 255.0 , alpha: 1.0)

                let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
                
                let gradientLayer: CAGradientLayer = CAGradientLayer()
                gradientLayer.colors = gradientColors
                gradientLayer.frame = self.layer.frame
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 1, y: 1)

                if self.gradientLayer != nil {
                    self.gradientLayer.removeFromSuperlayer()
                    self.gradientLayer = nil
                }

                self.gradientLayer = gradientLayer
                
                self.layer.insertSublayer(gradientLayer, at: 0)
            })
        }
    }

    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        DispatchQueue.main.async(execute: {
//            let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
//            let bottomColor = UIColor(red: 3.0 / 255.0, green: 70.0 / 255.0 , blue: 152.0 / 255.0 , alpha: 1.0)
            let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
            let bottomColor = UIColor(red: 3.0 / 255.0, green: 70.0 / 255.0 , blue: 152.0 / 255.0 , alpha: 1.0)

            let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
            
            let gradientLayer: CAGradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors
            gradientLayer.frame = self.layer.frame
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)

            if self.gradientLayer != nil {
                self.gradientLayer.removeFromSuperlayer()
                self.gradientLayer = nil
            }
            
            self.gradientLayer = gradientLayer

            self.layer.insertSublayer(gradientLayer, at: 0)
        })
    }
}
