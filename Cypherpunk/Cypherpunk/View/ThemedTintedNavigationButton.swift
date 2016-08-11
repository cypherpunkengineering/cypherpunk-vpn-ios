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
        self.setImage(self.imageView?.image, forState: .Normal)
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.tintColor = UIColor.whiteThemeNavigationButtonColor()
            self.setTitleColor(UIColor.whiteThemeNavigationColor(), forState: .Normal)
            self.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Highlighted)
            self.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Selected)
        case .Black:
            self.tintColor = UIColor.lightGrayColor()
            self.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    override func setImage(image: UIImage?, forState state: UIControlState) {
        if let image = image {
            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
            super.setImage(tintedImage, forState: state)
        } else {
            super.setImage(image, forState: state)
        }
    }

}
