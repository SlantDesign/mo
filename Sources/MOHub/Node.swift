// Copyright © 2017 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import CocoaAsyncSocket

/// Represents a node instance.
public final class Node {
    /// Network coniguration.
    public let networkConfiguration: NetworkConfiguration

    /// The node's identifier.
    public internal(set) var id = -1

    /// The node's IP address.
    public internal(set) var address: String

    /// Current node status.
    public internal(set) var status = Status.connecting

    /// Last ping response timestamp.
    public internal(set) var lastPingResponse: Date?

    /// Time elapsed since the last ping response.
    public var lag: TimeInterval {
        guard let date = lastPingResponse else {
            return -1
        }
        return NSDate().timeIntervalSince(date)
    }

    var socket: GCDAsyncUdpSocket
    weak var delegate: SocketManagerDelegate?

    /// Buffer for reading data
    var readBuffer = NSMutableData()

    init(networkConfiguration: NetworkConfiguration, address: String, socket: GCDAsyncUdpSocket, delegate: SocketManagerDelegate?) {
        self.networkConfiguration = networkConfiguration
        self.address = address
        self.socket = socket
        self.delegate = delegate
    }

    func sendHandshake() {
        let p = Packet(type: .handshake, id: -1)
        socket.send(p.serialize(), toHost: networkConfiguration.broadcastHost, port: networkConfiguration.nodePort, withTimeout: -1, tag: 0)
    }

    func processData(_ data: Data) {
        readBuffer.append(data)

        var readOffset = 0
        while readBuffer.length >= MemoryLayout<UInt32>.size {
            let packetSize = Int(readBuffer.bytes.advanced(by: readOffset).assumingMemoryBound(to: UInt32.self).pointee)
            if packetSize > 0 && readBuffer.length - readOffset >= packetSize {
                // We have all the data necessary for the packet
                let packetData = Data(bytes: readBuffer.bytes.advanced(by: readOffset).assumingMemoryBound(to: UInt8.self), count: packetSize)
                processPacketWithData(packetData)
                readOffset += packetSize
            } else {
                break
            }
        }

        // Move remaining data to the beginning of the buffer
        let remainingSize = readBuffer.length - readOffset
        readBuffer.replaceBytes(in: NSRange(location: 0, length: remainingSize), withBytes: readBuffer.bytes + readOffset)
        readBuffer.length -= readOffset
    }

    func processPacketWithData(_ data: Data) {
        var packet: Packet
        do {
            packet = try Packet(data)
        } catch {
            delegate?.handleError("Invalid packet received from \(id): \(error)")
            return
        }

        switch packet.packetType {
        case PacketType.handshake:
            id = packet.id
            status = .connected
            delegate?.handleStatus(status, node: self)

        case PacketType.ping:
            id = packet.id
            lastPingResponse = Date()

        default:
            break
        }

        delegate?.handlePacket(packet, node: self)
    }
}
