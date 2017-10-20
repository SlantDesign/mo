// Copyright © 2017 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import Foundation
import CocoaAsyncSocket

public final class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    /// Network configuration.
    public let networkConfiguration: NetworkConfiguration

    /// Delegate.
    public weak var delegate: SocketManagerDelegate?

    var queue = DispatchQueue(label: "SocketManager", attributes: [])
    var socket: GCDAsyncUdpSocket!

    /// A list of all the nodes by IP address
    public internal(set) var nodes = [String: Node]()

    weak var pingTimer: Timer?

    /// Initializes a `SocketManager` with a network configuration.
    public init(networkConfiguration: NetworkConfiguration) {
        self.networkConfiguration = networkConfiguration
        super.init()

        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue)
        socket.setIPv4Enabled(networkConfiguration.enableIPv4)
        socket.setIPv6Enabled(networkConfiguration.enableIPv6)

        pingTimer = Timer.scheduledTimer(timeInterval: networkConfiguration.pingInterval, target: self, selector: #selector(SocketManager.ping), userInfo: nil, repeats: true)
    }

    /// Broadcasts a packet to the network.
    public func sendPacket(_ packet: Packet) {
        socket.send(packet.serialize(), toHost: networkConfiguration.broadcastHost, port: networkConfiguration.nodePort, withTimeout: -1, tag: 0)
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var hostString: NSString? = NSString()
        var port: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&hostString, port: &port, fromAddress: address)

        guard let host = hostString as String? else {
            delegate?.handleError("Received data from a node with an invalid name")
            return
        }

        if let node = nodes[host] {
            node.processData(data)
        } else {
            let node = Node(networkConfiguration: networkConfiguration, address: host, socket: socket, delegate: delegate)
            nodes[host] = node
            node.processData(data)
        }
    }

    // MARK: - Pinging

    @objc func ping() {
        updateStatuses()
        let p = Packet(type: .ping, id: -1)
        socket.send(p.serialize(), toHost: networkConfiguration.broadcastHost, port: networkConfiguration.nodePort, withTimeout: -1, tag: 0)
    }

    func updateStatuses() {
        for node in nodes.values where node.lag > networkConfiguration.pingTimeout {
            // Disconnect if we don't get a ping for a while
            node.status = .disconnected
            delegate?.handleStatus(.disconnected, node: node)
            queue.async {
                self.nodes.removeValue(forKey: node.address)
            }
        }
    }
}
