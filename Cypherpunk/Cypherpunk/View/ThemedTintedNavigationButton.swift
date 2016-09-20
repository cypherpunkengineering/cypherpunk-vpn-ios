//
//  ThemedTintedNavigationButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedTintedNavigationButton: UIButton {

    override func awakeFromNib() {
        self.setImage(self.imageView?.image, for: .normal)
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.tintColor = UIColor.whiteThemeNavigationButtonColor()
            self.setTitleColor(UIColor.whiteThemeNavigationColor(), for: .normal)
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .highlighted)
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .selected)
        case .black:
            self.tintColor = UIColor.lightGray
            self.setTitleColor(UIColor.lightGray, for: .normal)
        case .indigo:
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        if let image = image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            super.setImage(tintedImage, for: state)
        } else {
            super.setImage(image, for: state)
        }
    }

}
