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
        reloadView()
    }
    
    func reloadView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            let image = UIImage(resource: R.image.logoGray_small)?.imageWithRenderingMode(.AlwaysTemplate)
            self.setImage(image, forState: .Normal)
            self.setImage(image, forState: .Disabled)
            self.tintColor = UIColor.whiteThemeTextColor()
            self.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Normal)
            self.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Disabled)
        case .Black:
            let image = UIImage(resource: R.image.logoGray_small)
            self.setImage(image, forState: .Normal)
            self.setImage(image, forState: .Disabled)
            self.tintColor = UIColor.lightGrayColor()
            self.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Normal)
            self.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
        }
    }
}
