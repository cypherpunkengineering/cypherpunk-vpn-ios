//
//  ThemedModeTableViewCell.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var privacyModeView: UIView!
    @IBOutlet weak var speedModeView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.titleLabel?.textColor = UIColor.whiteThemeTextColor()
            self.descriptionView?.textColor = UIColor.whiteThemeTextColor()
            privacyModeView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            speedModeView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.backgroundColor = UIColor.white
        case .Black:
            self.titleLabel?.textColor = UIColor.white
            self.descriptionView?.textColor = UIColor.white
            privacyModeView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            speedModeView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            self.backgroundColor = UIColor.blackThemeCellBackgroundColor()
        case .Indigo:
            self.titleLabel?.textColor = UIColor.white
            self.descriptionView?.textColor = UIColor.white
            privacyModeView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            speedModeView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            self.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        }
    }

}
