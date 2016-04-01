//  Copyright (c) 2015 C4. All rights reserved.

import Foundation
import Cocoa
import CocoaAsyncSocket
import CocoaLumberjack

public class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    static let masterID = Int(INT_MAX)
    static let masterPort = UInt16(10101)
    static let peripheralPort = UInt16(11111)
    static let broadcastHost = "255.255.255.255"
    static let pingInterval = 0.5
    
    static let sharedManager = SocketManager()

    var queue: dispatch_queue_t
    var socket: GCDAsyncUdpSocket!

    /// A list of all the peripherals by IP address
    var peripherals = [String: Peripheral]()

    /// Action invoked when there is a change in status
    var changeAction: (() -> Void)?

    weak var pingTimer: NSTimer?

    public override init() {
        queue = dispatch_queue_create("SocketManager", DISPATCH_QUEUE_SERIAL)
        super.init()

        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue)
        try! socket.enableBroadcast(true)
        try! socket.bindToPort(SocketManager.masterPort)
        try! socket.beginReceiving()

        pingTimer = NSTimer.scheduledTimerWithTimeInterval(SocketManager.pingInterval, target: self, selector: #selector(SocketManager.ping), userInfo: nil, repeats: true)
    }

    public func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        var hostString: NSString? = NSString()
        var port: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&hostString, port: &port, fromAddress: address)

        guard let host = hostString as? String else {
            DDLogWarn("Received data from an invalid host")
            return
        }

        if let peripheral = peripherals[host] {
            peripheral.processData(data)
        } else {
            let peripheral = Peripheral(address: host, socket: socket)
            peripheral.didReceivePacketAction = processPacket
            peripherals[host] = peripheral
            peripheral.processData(data)
        }
    }

    func processPacket(packet: Packet, peripheral: Peripheral) {
        switch packet.packetType {
        case .Handshake:
            dispatch_async(dispatch_get_main_queue()) {
                self.changeAction?()
            }

        case .Ping:
            dispatch_async(dispatch_get_main_queue()) {
                self.changeAction?()
            }

        default:
            break
        }
    }


    // MARK: - Pinging

    func ping() {
        updateStatuses()
        let p = Packet(type: .Ping, id: SocketManager.masterID)
        socket.sendData(p.serialize(), toHost: SocketManager.broadcastHost, port: SocketManager.peripheralPort, withTimeout: -1, tag: 0)
    }

    func updateStatuses() {
        for (_, p) in peripherals {
            if p.lag > Peripheral.pingTimeout {
                // Disconnect if we don't get a ping for a while
                p.status = .Disconnected
                DDLogVerbose("Disconnected from: \(p.id)")
                dispatch_async(queue) {
                    self.peripherals.removeValueForKey(p.address)
                }
            }
        }
    }
}
