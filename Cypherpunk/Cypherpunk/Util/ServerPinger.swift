//
//  ServerPingHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/6/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import GBPing
import RealmSwift

class ServerPinger : NSObject, GBPingDelegate {
    private var serversDone: Int = 0
    private var delegates = [PingHandler]()
    private var pingers = [GBPing]()
    
//    init() {
//
//    }
    
    func updateLatencyForServers() {
        serversDone = 0
        delegates.removeAll()
        
        let realm = try! Realm()
        let servers = realm.objects(Region.self)
        
        for server in servers {
            ping(server: server)
        }
    }
    
    func cancelPinging() {
        // Stops pinging servers and disregards any results that may have already returned
        let pingersToStop = pingers // make a copy of the pingers to stop
        
        delegates.removeAll()
        pingers.removeAll()
        
        pingersToStop.forEach { (pinger) in
            pinger.delegate = nil
            pinger.stop()
        }
    }
    
    func ping(server: Region) {
        let hostname = server.ovHostname
        
        let delegate = PingHandler(serverId: server.id, numPings: 2, pinger: self)
        
        let ping = GBPing()
        ping.host = hostname
        ping.timeout = 1.0
        ping.delegate = delegate
        
        ping.setup({ (success, error) in
            if (success) {
                ping.startPinging()
                self.delegates.append(delegate)
            }
            else {
//                print("Failed to setup pinger for \(hostname) - \(String(describing: error))")
            }
        })
    }
    
    func donePinging(serverId: String, results: [Double]) {
        // evaluate all the rtts and use the lowest one
        if let latency = results.min() {
            writeLatencyToRealm(serverId: serverId, latency: latency)
        }
        serversDone += 1
        
        if serversDone == delegates.count {
            // all servers are done, fire notification
            NotificationCenter.default.post(name: regionUpdateNotification, object: self)
        }
    }
    
    private func writeLatencyToRealm(serverId: String, latency: Double) {
        let realm = try! Realm()
        let region = realm.object(ofType: Region.self, forPrimaryKey: serverId)
        
        do {
            try realm.write {
                region?.latencySeconds = latency
            }
        } catch {
            print("Failed to udpate latency for \(serverId): \(error)")
        }
    }
}

class PingHandler : NSObject, GBPingDelegate {
    var rtts = [Double]()
    var serverId: String
    var numPings: UInt = 3
    var serverPinger: ServerPinger?
    
    // serverId,  number of pings, protocol
    init(serverId: String, numPings: Int, pinger: ServerPinger) {
        self.serverId = serverId
        self.serverPinger = pinger
        super.init()
    }
    
    func ping(_ pinger: GBPing!, didReceiveReplyWith summary: GBPingSummary!) {
//        print("\(serverId) - \(summary.rtt)")
        
        storePingValue(pingValue: summary.rtt, pinger: pinger, summary: summary)
    }
    
    func ping(_ pinger: GBPing!, didTimeoutWith summary: GBPingSummary!) {
//        print("Timeout > \(serverId)")
        
        // If a timeout occurs count it as a 10 second ping time
        storePingValue(pingValue: 10, pinger: pinger, summary: summary)
    }
    
    func ping(_ pinger: GBPing!, didReceiveUnexpectedReplyWith summary: GBPingSummary!) {
//        print("Unexpected Reply > \(serverId)")
        pinger.stop() // not sure what happened, stop pinging the server
        serverPinger?.donePinging(serverId: self.serverId, results: rtts)
    }
    
    func ping(_ pinger: GBPing!, didFailWithError error: Error!) {
        print("Error > \(serverId) - \(error)")
        pinger.stop() // error occured, stop pinging the server
        serverPinger?.donePinging(serverId: self.serverId, results: rtts)
    }
    
    private func storePingValue(pingValue: Double, pinger: GBPing, summary: GBPingSummary) {
        rtts.append(pingValue)
        
        // stop the pinging once threshold is reached
        if (summary.sequenceNumber == numPings) {
            pinger.stop()
            serverPinger?.donePinging(serverId: self.serverId, results: rtts)
        }
    }
}
