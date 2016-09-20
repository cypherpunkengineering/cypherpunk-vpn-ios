//
//  ThemedLogoView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedLogoView: UIButton {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            let image = UIImage(resource: R.image.logoGray_small)?.withRenderingMode(.alwaysTemplate)
            self.setImage(image, for: .normal)
            self.setImage(image, for: .disabled)
            self.tintColor = UIColor.whiteThemeTextColor()
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .normal)
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .disabled)
        case .black:
            let image = UIImage(resource: R.image.logoGray_small)
            self.setImage(image, for: .normal)
            self.setImage(image, for: .disabled)
            self.tintColor = UIColor.lightGray
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .normal)
            self.setTitleColor(UIColor.white, for: .disabled)
        case .indigo:
            let image = UIImage(resource: R.image.logoGray_small)
            self.setImage(image, for: .normal)
            self.setImage(image, for: .disabled)
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: .normal)
            self.setTitleColor(UIColor.white, for: .disabled)
        }
    }
}
