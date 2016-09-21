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

import KeychainAccess
struct AccountState: StateType {
    fileprivate struct AccountStateKey {
        static let isLoggedIn = "isLoggedIn"
        static let mailAddress = "mailAddress"
        static let password = "password"
        static let secret = "secret"
        static let nickName = "nickName"
        static let rawSubscriptionType = "rawSubscriptionType"
        static let expiredDate = "expiredDate"
    }

    var isLoggedIn: Bool
    var mailAddress: String?
    var password: String?
    var secret: String?
    var nickName: String?
    
    var subscriptionType: SubscriptionType
    var expiredDate: Date?
    
    func save() {
        let keychain = Keychain(service: mailAddress!)
        keychain[AccountStateKey.isLoggedIn] = String(isLoggedIn)
        keychain[AccountStateKey.mailAddress] = mailAddress
        keychain[AccountStateKey.password] = password
        keychain[AccountStateKey.secret] = secret
        keychain[AccountStateKey.nickName] = nickName
        keychain[AccountStateKey.rawSubscriptionType] = String(subscriptionType.rawValue)
        keychain[AccountStateKey.expiredDate] = String(describing: expiredDate)
        
        let inAppKeychain = Keychain.inAppKeychain()
        inAppKeychain[AccountStateKey.mailAddress] = mailAddress
    }
    
    static func restore() -> AccountState {
        var state = AccountState(isLoggedIn: false, mailAddress: nil, password: nil, secret: nil, nickName: nil, subscriptionType: .free, expiredDate: nil)
        let inAppKeychain = Keychain.inAppKeychain()
        if let service = inAppKeychain[AccountStateKey.mailAddress] {
            let keychain = Keychain(service: service)
            state.isLoggedIn = Bool(keychain[AccountStateKey.isLoggedIn] ?? "false")!
            state.mailAddress = keychain[AccountStateKey.mailAddress]
            state.password = keychain[AccountStateKey.password]
            state.secret = keychain[AccountStateKey.secret]
            state.nickName = keychain[AccountStateKey.nickName]
            state.subscriptionType = SubscriptionType(rawValue: Int(keychain[AccountStateKey.rawSubscriptionType] ?? "\( SubscriptionType.free.rawValue)")!)!
            let dateFormatter = DateFormatter()
            if let dateString = keychain[AccountStateKey.expiredDate] {
                state.expiredDate = dateFormatter.date(from: dateString)
            }
        }
        return state
    }
 
    static func removeLastLoggedInService() {
        let keychain = Keychain.inAppKeychain()
        keychain[AccountStateKey.mailAddress] = nil
    }
}
