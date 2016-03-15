//  Copyright (c) 2015 C4. All rights reserved.

import Foundation

public enum PacketMessage: Int8 {
    case Handshake
    case Disconnect
    case None
}

public enum PacketType: Int8 {
    case Connection
    case General
}

public enum MOObject: Int8 {
    case Core
    case Peripheral
    case None
}

public struct Packet: Equatable {
    public var type = PacketType.General
    public var message = PacketMessage.None

    public init(type: PacketType, message: PacketMessage) {
        self.type = type
        self.message = message
    }
    
    public func serialize() -> NSData {
        let data = NSMutableData()
        var t = type
        data.appendBytes(&t, length: sizeof(PacketType))
        var m = message
        data.appendBytes(&m, length: sizeof(PacketMessage))
        return data
    }
    
    public init(_ data: NSData) {
        var index = 0
        type = PacketType(rawValue: UnsafePointer<Int8>(data.bytes).memory)!
        index += sizeof(PacketType)
        message = PacketMessage(rawValue: UnsafePointer<Int8>(data.bytes + index).memory)!
        index += sizeof(PacketMessage)
    }
    
    public var description : String {
        return "Packet: \(type), \(message)"
    }
}

public func ==(lhs: Packet, rhs: Packet) -> Bool {
    return lhs.type == rhs.type &&
        lhs.message == rhs.message
}
