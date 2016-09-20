//
//  ThemeReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

struct ThemeReducer: Reducer {
    func handleAction(_ action: Action, state: ThemeState?) -> ThemeState {
        var state = state ?? ThemeState()
        
        if let action = action as? ThemeAction {
            switch action {
            case .ChangeToWhite:
                state.themeType = .white
                UIApplication.shared.changeStatusBarStyleToDefault()
            case .ChangeToBlack:
                state.themeType = .black
                UIApplication.shared.changeStatusBarStyleToLightContent()
            case .ChangeToIndigo:
                state.themeType = .indigo
                UIApplication.shared.changeStatusBarStyleToLightContent()
            }
        }
        return state
    }
}
