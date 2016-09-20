//
//  AccountState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

enum SubscriptionType: Int {
    case free
    case freePremium
    case oneMonth
    case halfYear
    case year
    
    var title: String {
        switch self {
        case .free: return "Free"
        case .freePremium: return "Free Premium"
        case .oneMonth: return "Monthly Premium"
        case .halfYear: return "6 Monthly Premium"
        case .year: return "Yearly Premium"
        }
    }
    
    var detailMessage: String {
        switch self {
        case .free: return ""
        case .freePremium: return "Expired At"
        default: return "Renews On"
        }
    }
}

struct AccountState: StateType {
    var isLoggedIn: Bool
    var mailAddress: String?
    var password: String?
    var secret: String?
    var nickName: String?
    
    var subscriptionType: SubscriptionType
    var expiredDate: Date?
}
