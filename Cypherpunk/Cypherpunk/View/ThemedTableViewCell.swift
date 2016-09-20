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
        self.textLabel?.font = R.font.dosisMedium(size: 18.0)
        self.detailTextLabel?.font = R.font.dosisMedium(size: 16.0)

        switch themeState.themeType {
        case .white:
            self.textLabel?.textColor = UIColor.whiteThemeTextColor()
            self.detailTextLabel?.textColor = UIColor.whiteThemeNavigationColor()
            self.backgroundColor = UIColor.white
        case .black:
            self.textLabel?.textColor = UIColor.white
            self.detailTextLabel?.textColor = UIColor.whiteThemeIndicatorColor()
            self.backgroundColor = UIColor.blackThemeCellBackgroundColor()
        case .indigo:
            self.textLabel?.textColor = UIColor.white
            self.detailTextLabel?.textColor = UIColor(white: 227.0 / 255.0, alpha: 1.0)
            self.backgroundColor = UIColor.white.withAlphaComponent(0.16)
            self.tintColor = UIColor.white
        }
    }

}

extension ThemedTableViewCell {
    func prepareDisclosureIndicator() {
        for case let button as UIButton in subviews {
            let image = button.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
            button.setBackgroundImage(image, for: .normal)
        }
    }
}
