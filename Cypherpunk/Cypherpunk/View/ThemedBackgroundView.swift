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
        case .white:
            self.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0 , blue: 242.0 / 255.0 , alpha: 1.0)
        case .black:
            self.backgroundColor = UIColor.black
        case .indigo:
            DispatchQueue.main.async(execute: { 
                let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
                let bottomColor = UIColor(red: 3.0 / 255.0, green: 70.0 / 255.0 , blue: 152.0 / 255.0 , alpha: 1.0)
                let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
                
                let gradientLayer: CAGradientLayer = CAGradientLayer()
                gradientLayer.colors = gradientColors
                gradientLayer.frame = self.layer.frame
                
                self.layer.insertSublayer(gradientLayer, at: 0)
            })
        }
    }
}
