//
//  PacketTest.swift
//  PacketTest
//
//  Created by travis on 2016-03-15.
//  Copyright © 2016 C4. All rights reserved.
//

import XCTest

class PacketTest: XCTestCase {

    func testSerialize() {
        let type = PacketType.Scroll
        let id = 17

        let packet = Packet(type: type, id: id, data: nil)
        let data = packet.serialize()
        var array = [Int8](count: data.length, repeatedValue: 0)
        data.getBytes(&array, length: data.length)

        let packetSize = Int(UnsafePointer<UInt32>(data.bytes).memory)
        XCTAssertEqual(packetSize, Packet.basePacketSize)

        XCTAssertEqual(array[4], type.rawValue)

        let serializedId = Int(UnsafePointer<Int32>(data.bytes + 5).memory)
        XCTAssertEqual(serializedId, id)
    }

    func testRoundtrip() {
        let type = PacketType.Handshake
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
