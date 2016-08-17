//
//  ThemedNavigationBar.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedNavigationBar: UINavigationBar {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.tintColor = UIColor.whiteThemeNavigationColor()
            self.barTintColor = UIColor.whiteThemeTableViewBackgroundColor()
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteThemeTextColor()]
        case .Black:
            self.barTintColor = UIColor.whiteColor()
            self.tintColor = UIColor.blackColor()
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        case .Indigo:
            // 113 164 231
            // 105 158 225
            dispatch_async(dispatch_get_main_queue(), {
                let topColor = UIColor(red: 113.0 / 255.0, green: 164.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
                let bottomColor = UIColor(red: 105.0 / 255.0, green: 158.0 / 255.0 , blue: 225.0 / 255.0 , alpha: 1.0)
                let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
                
                let gradientLayer: CAGradientLayer = CAGradientLayer()
                gradientLayer.colors = gradientColors
                gradientLayer.frame = self.layer.frame
                
                self.layer.insertSublayer(gradientLayer, atIndex: 0)
            })

            self.translucent = true
            self.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.barTintColor = UIColor.clearColor()
            self.tintColor = UIColor.whiteColor()
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
    }
}
