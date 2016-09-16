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
        var state: StatusState = state ?? StatusState(
            originalIPAddress: nil,
            newIPAddress: nil,
            originalLongitude: nil,
            originalLatitude: nil,
            newLongitude: nil,
            newLatitude: nil,
            originalCountry: nil,
            newCountry: nil,
            connectedDate: nil)
        
        if let action = action as? StatusAction {
            switch action {
            case .GetOriginalIPAddress(let address):
                state.originalIPAddress = address
                state.newIPAddress = nil
                state.newLatitude = nil
                state.newLongitude = nil
                state.newCountry = nil
            case .GetNewIPAddress(let address):
                if state.originalIPAddress != address {
                    state.newIPAddress = address                    
                }
            case .GetOriginalGeoLocation(let response):
                if state.originalIPAddress == response.query {
                    state.originalLatitude = response.lat
                    state.originalLongitude = response.lon
                    state.originalCountry = response.country
                }
            case .GetNewGeoLocation(let response):
                if state.newIPAddress == response.query {
                    state.newLatitude = response.lat
                    state.newLongitude = response.lon
                    state.newCountry = response.country
                }
            case .SetConnectedDate(let date):
                state.connectedDate = date
            }
        }
        
        return state
    }
}