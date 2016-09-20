//
//  ThemedNavigationButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedNavigationButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.setImage(self.imageView?.image, for: UIControlState())
            self.tintColor = UIColor.whiteThemeNavigationButtonColor()
            self.setTitleColor(UIColor.whiteThemeNavigationColor(), for: UIControlState())
            self.setTitleColor(UIColor.lightGray, for: .highlighted)
            self.setTitleColor(UIColor.lightGray, for: .selected)
        case .Black:
            self.setImage(self.imageView?.image, for: UIControlState())
            self.tintColor = UIColor.lightGray
            self.setTitleColor(UIColor.lightGray, for: UIControlState())
        case .Indigo:
            self.setImage(self.imageView?.image, for: UIControlState())
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: UIControlState())
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
