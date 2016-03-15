//  Copyright (c) 2015 C4. All rights reserved.

import Foundation
import Cocoa
import CocoaAsyncSocket
import CocoaLumberjackSwift

public class SocketManager: NSObject, GCDAsyncSocketDelegate {
    static let sharedManager = SocketManager()

    //The current ID
    let deviceID = NSUserDefaults.standardUserDefaults().integerForKey("deviceID")

    //The main socket, all peripherals will connect to this
    var socket: GCDAsyncSocket?

    //A list of all the sockets that have been connected
    var connectedSockets = [GCDAsyncSocket]()

    public override init() {
        super.init()
        initializeSocketOnPort(10101)
    }

    func initializeSocketOnPort(port: UInt16) {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket?.acceptOnPort(port)
            socket?.delegate = self
            DDLogVerbose("\(deviceID): Initialized Socket on port \(port)")
        } catch {
            DDLogVerbose("\(deviceID): Coult not initialize socket using acceptOnPort(\(port))")
        }
    }

    public func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        DDLogVerbose("Accepted sock: \(sock) from: \(newSocket.connectedHost):\(newSocket.connectedPort)")
        if sock == socket {
            connectedSockets.append(newSocket)
            let p = Packet(type: PacketType.Connection, message: PacketMessage.Handshake)
            writeTo(newSocket, packet: p)
        }
    }

    public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        DDLogVerbose("\(deviceID) Incoming data from: \(sock)")
        sock.readDataWithTimeout(-1, tag: 0)

        let packet = Packet(data)

        if packet.message == .Handshake {
            DDLogVerbose("Shook hands with peripheral")
        } else {
            DDLogVerbose("Unknown Data: \(packet)")
        }
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

    public func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLogVerbose("Disconnecting from: \(sock), [\(connectedSockets.count)]")
        if let index = connectedSockets.indexOf(sock) {
            connectedSockets.removeAtIndex(index)
            sock.disconnect()
            DDLogVerbose("\tDisconnected from: \(sock), [\(connectedSockets.count)]")
        }
    }

    public func disconnectAll() {
        DDLogVerbose("\(deviceID) is disconnecting from all sockets")
        for socket in connectedSockets {
            socket.delegate = nil
            socket.disconnect()
        }

        connectedSockets.removeAll()
    }
}