//
//  ThemedBackgroundView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedBackgroundView: UIView {

    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0 , blue: 242.0 / 255.0 , alpha: 1.0)
        case .Black:
            self.backgroundColor = UIColor.blackColor()
        case .Indigo:
            dispatch_async(dispatch_get_main_queue(), { 
                let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
                let bottomColor = UIColor(red: 3.0 / 255.0, green: 70.0 / 255.0 , blue: 152.0 / 255.0 , alpha: 1.0)
                let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
                
                let gradientLayer: CAGradientLayer = CAGradientLayer()
                gradientLayer.colors = gradientColors
                gradientLayer.frame = self.layer.frame
                
                self.layer.insertSublayer(gradientLayer, atIndex: 0)
            })
        }
    }
}
