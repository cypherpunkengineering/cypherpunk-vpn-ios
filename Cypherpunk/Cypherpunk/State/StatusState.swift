//
//  StatusState.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

struct StatusState: StateType {
    var originalIPAddress: String?
    var newIPAddress: String?
}