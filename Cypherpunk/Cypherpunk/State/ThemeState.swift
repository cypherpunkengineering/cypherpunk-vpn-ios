//
//  ThemeState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

enum ThemeType: Int {
    case White
    case Black
}

struct ThemeState: StateType {
    var themeType: ThemeType = .White
}