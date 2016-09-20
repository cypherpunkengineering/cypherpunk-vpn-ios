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
    
    typealias ReducerStateType = ThemeState
    
    func handleAction(action: Action, state: ThemeState?) -> ThemeState {
        var state = state ?? ThemeState()
        
        if let action = action as? ThemeAction {
            switch action {
            case .changeToWhite:
                state.themeType = .white
                UIApplication.shared.changeStatusBarStyleToDefault()
            case .changeToBlack:
                state.themeType = .black
                UIApplication.shared.changeStatusBarStyleToLightContent()
            case .changeToIndigo:
                state.themeType = .indigo
                UIApplication.shared.changeStatusBarStyleToLightContent()
            }
        }
        return state
    }
}
