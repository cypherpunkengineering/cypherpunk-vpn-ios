//
//  StatusAction.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

enum StatusAction: Action {
    case GetOriginalIPAddress(address: String)
    case GetNewIPAddress(address: String)
}