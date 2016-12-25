//  Copyright © 2016 Slant. All rights reserved.

import Foundation

public enum PacketType: Int8 {
    /// First packet sent when a connection is made, used to identify the peripheral
    case handshake

    /// Packet sent periodically to measure lag and detect disconnected peripherals
    case ping

    /// Packet sent for scroll events
    case scroll

    /// Packet sent when a device is done controlling scroll events
    case cease

    /// Packet sent when a shape is added to the collectionView
    case resonateShape

    /// Packet sent when it's time to change universes
    case switchUniverse

    /// Animation sync packer
    case sync
}

enum PacketInitializationError: Error {
    case notEnoughData
    case invalidPacketType
}

public struct Packet: Equatable {
    public static let basePacketSize = MemoryLayout<UInt32>.size + MemoryLayout<PacketType>.size + MemoryLayout<Int32>.size

    public var packetType: PacketType
    public var id = -1
    public var data: Data?

    public init(type: PacketType, id: Int, data: Data? = nil) {
        self.packetType = type
        self.id = id
        self.data = data
    }
    
    public func serialize() -> Data {
        let packetData = NSMutableData()

        // The first element in the packet data needs to be the packet size to know if we have enought data to build the packet.
        let dataSize = data?.count ?? 0
        var packetSize = UInt32(Packet.basePacketSize + dataSize)
        packetData.append(&packetSize, length: MemoryLayout.size(ofValue: packetSize))

        var t = packetType.rawValue
        packetData.append(&t, length: MemoryLayout.size(ofValue: t))

        var i = Int32(id)
        packetData.append(&i, length: MemoryLayout.size(ofValue: i))

        if let d = data, d.count > 0 {
            packetData.append(d as Data)
        }
        return packetData as Data
    }
    
    public init(_ packetData: Data) throws {
        var index = 0

        let packetSize = packetData.extract(UInt32.self, at: index)
        if packetData.count < Int(packetSize) {
            throw PacketInitializationError.notEnoughData
        }
        index += MemoryLayout.size(ofValue: packetSize)

        guard let t = PacketType(rawValue: packetData.extract(Int8.self, at: index)) else {
            throw PacketInitializationError.invalidPacketType
        }
        packetType = t
        index += MemoryLayout.size(ofValue: t)

        id = packetData.extract(Int.self, at: index)
        index += MemoryLayout<Int32>.size

        let dataLength = Int(packetSize) - Packet.basePacketSize
        if dataLength > 0 {
            data = packetData.subdata(in: packetData.startIndex.advanced(by: index) ..< packetData.startIndex.advanced(by: index + dataLength))
        }
    }
    
    public var description : String {
        return "Packet: \(packetType), \(id), \(data == nil ? "No Data" : "\(data!.count) bytes of Data")"
    }
}

public func ==(lhs: Packet, rhs: Packet) -> Bool {
    return lhs.packetType == rhs.packetType && lhs.id == rhs.id
}
