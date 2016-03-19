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
    var peripherals = [Peripheral]()

    var readBuffer = NSMutableData()

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
        DDLogVerbose("Accepted connection from: \(newSocket.connectedHost)")

        let peripheral = Peripheral(socket: newSocket)
        peripheral.didReceivePacketAction = processPacket
        peripherals.append(peripheral)
        peripheral.sendHandshake(deviceID)
    }

    func processPacket(packet: Packet, peripheral: Peripheral) {
        switch packet.packetType {
        case .Scroll:
            forwardScroll(packet, excluding: peripheral)
            return

        case .Handshake:
            // Ignore
            break

        default:
            DDLogVerbose("Invalid packet type received from \(peripheral.id): \(packet)")
        }
    }

    func forwardScroll(packet: Packet, excluding peripheral: Peripheral) {
        let data = packet.serialize()
        for p in peripherals {
            if p !== peripheral {
                writeTo(p.socket, data: data)
            }
        }
    }

    func writeTo(sock: GCDAsyncSocket, packet: Packet, tag: Int = 0) {
        writeTo(sock, data: packet.serialize(), tag: tag)
    }

    func writeTo(sock: GCDAsyncSocket, data: NSData, tag: Int = 0) {
        sock.writeData(data, withTimeout: -1, tag: tag)
    }

    func peripheralDidDisconnect(peripheral: Peripheral) {
        if let index = peripherals.indexOf(peripheral) {
            peripherals.removeAtIndex(index)
        }
    }

    public func disconnectAll() {
        DDLogVerbose("\(deviceID) is disconnecting from all sockets")
        for p in peripherals {
            p.socket.disconnect()
        }

        peripherals.removeAll()
    }
}
