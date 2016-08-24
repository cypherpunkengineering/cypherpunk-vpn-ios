//
//  StatusReducer.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

struct StatusReducer: Reducer {
    func handleAction(action: Action, state: StatusState?) -> StatusState {
        var state: StatusState = state ?? StatusState(originalIPAddress: nil, newIPAddress: nil)
        
        if let action = action as? StatusAction {
            switch action {
            case .GetOriginalIPAddress(let address):
                state.originalIPAddress = address
                state.newIPAddress = nil
            case .GetNewIPAddress(let address):
                state.newIPAddress = address
            }
        }
        
        return state
    }
}