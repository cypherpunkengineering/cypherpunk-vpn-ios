//
//  ThemedChangeIPAddressButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedChangeIPAddressButton: UIButton {

    override func awakeFromNib() {
        let image = UIImage(resource: R.image.icon_refresh)?.imageWithRenderingMode(.AlwaysTemplate)
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
            self.tintColor = UIColor.whiteColor()
            self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.borderColor = UIColor.whiteColor()
        case .Indigo:
            self.tintColor = UIColor.whiteColor()
            self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.borderColor = UIColor.whiteColor()            
        }
    }

}
