//
//  ThemedTableViewCell.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        prepareDisclosureIndicator()
        configureView()
    }
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.textLabel?.textColor = UIColor.whiteThemeTextColor()
            self.detailTextLabel?.textColor = UIColor.whiteThemeNavigationColor()
            self.backgroundColor = UIColor.whiteColor()
        case .Black:
            self.textLabel?.textColor = UIColor.whiteColor()
            self.detailTextLabel?.textColor = UIColor.whiteThemeIndicatorColor()
            self.backgroundColor = UIColor.blackThemeCellBackgroundColor()
        case .Indigo:
            self.textLabel?.textColor = UIColor.whiteColor()
            self.detailTextLabel?.textColor = UIColor(white: 227.0 / 255.0, alpha: 1.0)
            self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.16)
            self.tintColor = UIColor.whiteColor()
        }
    }

}

extension ThemedTableViewCell {
    func prepareDisclosureIndicator() {
        for case let button as UIButton in subviews {
            let image = button.backgroundImageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate)
            button.setBackgroundImage(image, forState: .Normal)
        }
    }
}