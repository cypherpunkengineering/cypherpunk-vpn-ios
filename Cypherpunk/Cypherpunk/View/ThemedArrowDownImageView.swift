//
//  ThemedArrowDownImageView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedArrowDownImageView: UIImageView {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            let image = UIImage(resource: R.image.arrow_down)?.imageWithRenderingMode(.AlwaysTemplate)
            self.image = image
            self.tintColor = UIColor.whiteThemeNavigationColor()
        case .Black:
            let image = UIImage(resource: R.image.arrow_down)
            self.image = image
            self.tintColor = UIColor.lightGrayColor()
        }
    }
}
