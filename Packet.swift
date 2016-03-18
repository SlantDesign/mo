//  Copyright (c) 2015 C4. All rights reserved.

import Foundation

public enum PacketMessage: Int8 {
    case Handshake
    case Bubbles
    case Sync
    case Alignment
    case Bars
    case Scroll
    case None
}

public enum PacketType: Int8 {
    case Connection
    case Gesture
    case Scroll
    case SwitchUniverse
    case General
}

enum PacketInitializationError: ErrorType {
    case NotEnoughData
    case InvalidPacketType
    case InvalidPacketMessage
    case ID
    case DataLength
    case Data
}

import CocoaLumberjackSwift

public struct Packet: Equatable {
    public static let basePacketSize = sizeof(UInt32) + sizeof(PacketType) + sizeof(PacketMessage) + sizeof(Int32)

    public var packetType = PacketType.General
    public var message = PacketMessage.None
    public var id = -1
    public var data: NSData?

    public init(type: PacketType, message: PacketMessage, id: Int, data: NSData? = nil) {
        self.packetType = type
        self.message = message
        self.id = id
        self.data = data
    }
    
    public func serialize() -> NSData {
        let packetData = NSMutableData()

        // The first element in the packet data needs to be the packet size to know if we have enought data to build the packet.
        let dataSize = data?.length ?? 0
        var packetSize = UInt32(Packet.basePacketSize + dataSize)
        packetData.appendBytes(&packetSize, length: sizeofValue(packetSize))

        var t = packetType.rawValue
        packetData.appendBytes(&t, length: sizeofValue(t))

        var m = message.rawValue
        packetData.appendBytes(&m, length: sizeofValue(m))

        var i = Int32(id)
        packetData.appendBytes(&i, length: sizeofValue(i))

        if let d = data {
            packetData.appendData(d)
        }
        return packetData
    }
    
    public init(_ packetData: NSData) throws {
        var index = 0

        let packetSize = UnsafePointer<UInt32>(packetData.bytes + index).memory
        if packetData.length < Int(packetSize) {
            throw PacketInitializationError.NotEnoughData
        }
        index += sizeofValue(packetSize)

        guard let t = PacketType(rawValue: UnsafePointer<Int8>(packetData.bytes + index).memory) else {
            throw PacketInitializationError.InvalidPacketType
        }
        packetType = t
        index += sizeofValue(t)

        guard let m = PacketMessage(rawValue: UnsafePointer<Int8>(packetData.bytes + index).memory) else {
            throw PacketInitializationError.InvalidPacketMessage
        }
        message = m
        index += sizeofValue(m)

        id = Int(UnsafePointer<Int32>(packetData.bytes + index).memory)
        index += sizeof(Int32)

        let dataLength = Int(packetSize) - Packet.basePacketSize
        if dataLength > 0 {
            data = NSData(bytes: UnsafePointer<Void>(packetData.bytes + index), length: dataLength)
        }
    }
    
    public var description : String {
        return "Packet: \(packetType), \(message), \(id), \(data == nil ? "No Data" : "\(data!.length) bytes of Data")"
    }
}

public func ==(lhs: Packet, rhs: Packet) -> Bool {
    return lhs.packetType == rhs.packetType &&
        lhs.message == rhs.message
}
