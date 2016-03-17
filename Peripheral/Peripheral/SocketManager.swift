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
import CocoaLumberjackSwift

//let currentHost = "192.168.0.11"
//let currentHost = "169.254.176.152"
let currentHost = "169.254.102.150"

public class SocketManager : NSObject, GCDAsyncSocketDelegate {
    static let sharedManager = SocketManager()

    var workspace: WorkSpace?
    
    var deviceID = NSUserDefaults.standardUserDefaults().integerForKey("deviceID")

    //a list of addresses that point to a broadcast NSNetService
    var serverAddresses : [NSData]?

    //the socket that will be used to connect to the core app
    var socket : GCDAsyncSocket?

    public override init() {
        super.init()
        initializeSocketWithHost(currentHost, port: 10101)
    }

    func initializeSocketWithHost(host: String, port: UInt16) {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket?.delegate = self
        do {
            //doesn't work without specifying the timeout (2h)
            try socket?.connectToHost(host, onPort: port, withTimeout: 1)
            DDLogVerbose("Trying to connect to host \(host) on port \(port)")
        } catch {
            DDLogVerbose("\(deviceID): Could not connect to host \(host) on port \(port)")
        }
    }

    public func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DDLogVerbose("Connected to host \(host) on port \(port)")
        let packet = Packet(type: PacketType.Connection, message: PacketMessage.Handshake, id: deviceID)
        writeTo(sock, data: packet.serialize())
    }

    func writeTo(sock: GCDAsyncSocket, packet: Packet, tag: Int = 0) {
        writeTo(sock, data: packet.serialize(), tag: tag)
    }

    func writeTo(sock: GCDAsyncSocket, data: NSData, tag: Int = 0) {
        let data = NSMutableData(data: data)
        //appends an extra bit of data that acts as an "end point" for reading
        data.appendData(GCDAsyncSocket.CRLFData())
        //writes the full data to the socket
        sock.writeData(data, withTimeout: -1, tag: tag)
        //tells the socket to read until it reaches the "end point"
        sock.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: 0)
    }

    public func sendPacket(packet: Packet) {
        if let sock = socket {
            writeTo(sock, data: packet.serialize())
        }
    }

    public func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLogVerbose("\(deviceID) disconnected from \(sock)")
        socket?.disconnect()
        socket = nil

        wait(0.1) {
            self.initializeSocketWithHost(currentHost, port: 10101)
        }
    }

    public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        var packet: Packet!
        do {
            packet = try Packet(data)
        } catch {
            DDLogVerbose("Could not initialize packet from data: \(error)")
            return
        }

        switch packet.packetType {
        case .Connection:
            if packet.message == .Handshake {
                DDLogVerbose("\(deviceID) shook hands with \(sock)")
            }
        default:
            workspace?.receivePacket(packet)
        }
        sock.readDataWithTimeout(-1, tag: 0)
    }
}