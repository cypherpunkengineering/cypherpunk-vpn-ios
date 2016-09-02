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
    case Free
    case FreePremium
    case OneMonth
    case HalfYear
    case Year
    
    var title: String {
        switch self {
        case .Free: return "Free"
        case .FreePremium: return "Free Premium"
        case .OneMonth: return "Monthly Premium"
        case .HalfYear: return "6 Monthly Premium"
        case .Year: return "Yearly Premium"
        }
    }
    
    var detailMessage: String {
        switch self {
        case .Free: return ""
        case .FreePremium: return "Expired At"
        default: return "Renews On"
        }
    }
}

struct AccountState: StateType {
    var isLoggedIn: Bool
    var mailAddress: String
    var password: String
    var secret: String
    var nickName: String
    
    var subscriptionType: SubscriptionType
    var expiredDate: NSDate?
}