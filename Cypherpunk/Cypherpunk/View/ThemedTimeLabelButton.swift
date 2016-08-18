//
//  ThemedTimeLabelButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedTimeLabelButton: UIButton {
    
    override func awakeFromNib() {
        let image = UIImage(resource: R.image.icon_time)?.imageWithRenderingMode(.AlwaysTemplate)
        self.setImage(image, forState: .Normal)
        
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.tintColor = UIColor.whiteThemeTextColor()
            self.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Normal)
            self.borderColor = UIColor.whiteThemeTextColor()
        case .Black:
            self.tintColor = UIColor.blackThemeTextColor()
            self.setTitleColor(UIColor.blackThemeTextColor(), forState: .Normal)
            self.borderColor = UIColor.blackThemeTextColor()
        case .Indigo:
            self.tintColor = UIColor.blackThemeTextColor()
            self.setTitleColor(UIColor.blackThemeTextColor(), forState: .Normal)
            self.borderColor = UIColor.blackThemeTextColor()
        }
    }

}
