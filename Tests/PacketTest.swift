//  Copyright © 2016 Slant. All rights reserved.

import MO
import XCTest

class PacketTest: XCTestCase {

    func testSerialize() {
        let type = PacketType.scroll
        let id = 17

        let packet = Packet(type: type, id: id, data: nil)
        let data = packet.serialize()
        var array = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &array, count: data.count)

        let packetSize = Int(data.extract(UInt32.self, at: 0))
        XCTAssertEqual(packetSize, Packet.basePacketSize)

        XCTAssertEqual(array[4], UInt8(type.rawValue))

        let serializedId = Int(data.extract(Int32.self, at: 5))
        XCTAssertEqual(serializedId, id)
    }

    func testRoundtrip() {
        let type = PacketType.handshake
        let id = 17

        let expectedPacket = Packet(type: type, id: id, data: nil)
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
