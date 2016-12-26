// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import MO
import XCTest

class PacketTest: XCTestCase {

    func testSerialize() {
        let type = PacketType(rawValue: 4)
        let id = 17

        let packet = Packet(type: type, id: id, payload: nil)
        let data = packet.serialize()
        var array = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &array, count: data.count)

        let packetSize = Int(data.extract(UInt32.self, at: 0))
        XCTAssertEqual(packetSize, Packet.basePacketSize)

        let packetType = data.extract(UInt32.self, at: 4)
        XCTAssertEqual(packetType, UInt32(type.rawValue))

        let serializedId = Int(data.extract(Int32.self, at: 8))
        XCTAssertEqual(serializedId, id)
    }

    func testRoundtrip() {
        let type = PacketType.handshake
        let id = 17

        let expectedPacket = Packet(type: type, id: id, payload: nil)
        let data = expectedPacket.serialize()
        var actualPacket: Packet?
        do {
            actualPacket = try Packet(data)
        } catch {
            print("Could not initialize packet, during tests: \(error)")
        }
        XCTAssertEqual(actualPacket, expectedPacket)
    }
}
