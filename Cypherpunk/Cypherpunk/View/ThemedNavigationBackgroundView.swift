//
//  ThemedNavigationBackgroundView.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedNavigationBackgroundView: UIView {

    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.isHidden = true
        case .Black:
            self.isHidden = true
        case .Indigo:
            self.isHidden = false
            
            DispatchQueue.main.async(execute: {
                
                let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
                let bottomColor = UIColor(red: 105 / 255.0, green: 158 / 255.0 , blue: 225 / 255.0 , alpha: 1.0)
                let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
                
                let gradientLayer: CAGradientLayer = CAGradientLayer()
                gradientLayer.colors = gradientColors
                gradientLayer.frame = self.layer.frame
                
                self.layer.insertSublayer(gradientLayer, at: 0)
            })
            
        }
    }

}
