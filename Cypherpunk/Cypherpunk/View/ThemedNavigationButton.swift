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
        reloadView()
    }
    
    func reloadView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.setImage(self.imageView?.image, forState: .Normal)
            self.tintColor = UIColor.whiteThemeNavigationButtonColor()
            self.setTitleColor(UIColor.whiteThemeNavigationColor(), forState: .Normal)
            self.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
            self.setTitleColor(UIColor.lightGrayColor(), forState: .Selected)
        case .Black:
            self.setImage(self.imageView?.image, forState: .Normal)
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
