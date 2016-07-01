//
//  AppReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/17.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct AppReducer: Reducer {
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        return AppState(
            loginState: LoginReducer.handleAction(action, state: state?.loginState)
        )
    }
}