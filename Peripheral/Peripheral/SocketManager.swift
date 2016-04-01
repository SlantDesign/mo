//
//  SocketManager.swift
//  Peripheral
//
//  Created by travis on 2016-03-15.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import Foundation
import CocoaAsyncSocket
import CocoaLumberjack

public class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    static let portNumber = UInt16(10101)
    static let masterHost = "192.168.0.11"
    static let broadcastHost = "255.255.255.255"

    static let sharedManager = SocketManager()

    var workspace: WorkSpace?
    
    var deviceID = NSUserDefaults.standardUserDefaults().integerForKey("deviceID")
    var maxDeviceID = 0

    //the socket that will be used to connect to the core app
    var socket: GCDAsyncUdpSocket!

    public override init() {
        super.init()

        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        try! socket.enableBroadcast(true)
        try! socket.beginReceiving()

        let packet = Packet(type: .Handshake, id: deviceID)
        socket.sendData(packet.serialize(), toHost: SocketManager.masterHost, port: SocketManager.portNumber, withTimeout: -1, tag: 0)
    }

    public func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        var packet: Packet!
        do {
            packet = try Packet(data)
        } catch {
            DDLogVerbose("Could not initialize packet from data: \(error)")
            return
        }

        switch packet.packetType {
        case .Handshake:
            maxDeviceID = max(maxDeviceID, packet.id)
            DDLogVerbose("\(deviceID) shook hands with \(sock)")

        case .Ping:
            let packet = Packet(type: .Ping, id: deviceID)
            socket.sendData(packet.serialize(), toHost: SocketManager.masterHost, port: SocketManager.portNumber, withTimeout: -1, tag: 0)

        default:
            workspace?.receivePacket(packet)
        }
    }

    public func broadcastPacket(packet: Packet) {
        socket.sendData(packet.serialize(), toHost: SocketManager.broadcastHost, port: SocketManager.portNumber, withTimeout: -1, tag: 0)
    }
}
