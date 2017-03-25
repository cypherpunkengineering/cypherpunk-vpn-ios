//
//  VPNStateResponder.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/17/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

protocol VPNStateResponder : class {
    func disconnected(disconnectedOption: VPNServerOption?)
    func connected(disconnectedOption: VPNServerOption?, connectedOption: VPNServerOption?)
}
