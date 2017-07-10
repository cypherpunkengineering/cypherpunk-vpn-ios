//
//  AccountAction.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

enum AccountAction: Action {
    case signUp(mailAddress: String, session: String)
    case login(response: LoginResponse)
    case upgrade(subscription: SubscriptionType?, expiredDate: Date?)
    case changeEmail(newEmail: String)
    case changePassword(password: String)
    case logout
    case certificate(p12: String)
}
