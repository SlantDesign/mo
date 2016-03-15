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
    case PacketType
    case PacketMessage
    case ID
    case DataLength
    case Data
}

public struct Packet: Equatable {
    public var type = PacketType.General
    public var message = PacketMessage.None
    public var id = -1
    public var data: NSData?
    var dataLength = 0

    public init(type: PacketType, message: PacketMessage, id: Int, data: NSData? = nil) {
        self.type = type
        self.message = message
        self.id = id
        self.data = data

        if let d = self.data {
            dataLength = d.length
        } else {
            dataLength = 0
        }
    }
    
    public func serialize() -> NSData {
        let packetData = NSMutableData()
        var t = type
        packetData.appendBytes(&t, length: sizeof(PacketType))
        var m = message
        packetData.appendBytes(&m, length: sizeof(PacketMessage))
        var i = id
        packetData.appendBytes(&i, length: sizeof(Int))
        var dl = dataLength
        packetData.appendBytes(&dl, length: sizeof(Int))
        if var d = self.data where dl > 0 {
            packetData.appendBytes(&d, length: dataLength)
        }
        return packetData
    }
    
    public init(_ packetData: NSData) throws {
        var index = 0

        guard let t = PacketType(rawValue: UnsafePointer<Int8>(packetData.bytes).memory) else {
            throw PacketInitializationError.PacketType
        }
        type = t
        index += sizeof(PacketType)

        guard let m = PacketMessage(rawValue: UnsafePointer<Int8>(packetData.bytes + index).memory) else {
            throw PacketInitializationError.PacketMessage
        }
        message = m
        index += sizeof(PacketMessage)

        id = UnsafePointer<Int>(packetData.bytes + index).memory
        index += sizeof(Int)

        dataLength = UnsafePointer<Int>(packetData.bytes+index).memory
        index += sizeof(Int)

        if dataLength > 0 {
            data = NSData(bytes: UnsafePointer<Void>(packetData.bytes+index), length: dataLength)
        }
    }
    
    public var description : String {
        return "Packet: \(type), \(message), \(id), \(dataLength), \(data == nil ? "No Data" : "Data Exists")"
    }
}

public func ==(lhs: Packet, rhs: Packet) -> Bool {
    return lhs.type == rhs.type &&
        lhs.message == rhs.message
}
