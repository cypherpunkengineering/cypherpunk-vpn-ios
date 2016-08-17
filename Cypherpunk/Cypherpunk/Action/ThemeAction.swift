//
//  ThemeAction.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

let KeyChangeThemeNotification = "KeyChangeThemeNotification"

enum ThemeAction: Action {
    case ChangeToWhite
    case ChangeToBlack
    case ChangeToIndigo
}