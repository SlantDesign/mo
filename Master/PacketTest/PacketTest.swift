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
        let type = PacketType.General
        let message = PacketMessage.Bubbles
        let id = 17

        let packet = Packet(type: type, message: message, id: id, data: nil)
        let data = packet.serialize()
        var array = [Int8](count: data.length, repeatedValue: 0)
        data.getBytes(&array, length: data.length)

        XCTAssertEqual(array[0], type.rawValue)
        XCTAssertEqual(array[1], message.rawValue)

        let serializedId = UnsafePointer<Int>(data.bytes + 3).memory
        XCTAssertEqual(serializedId, id)

        let dataLengthLengthIndex = 3 + sizeof(Int)
        let serializedInfoLength = UnsafePointer<Int>(data.bytes + dataLengthLengthIndex).memory
        XCTAssertEqual(serializedInfoLength, 0)
    }

    func testRoundtrip() {
        let type = PacketType.General
        let message = PacketMessage.Handshake
        let id = 17

        let expectedPacket = Packet(type: type, message: message, id: id, data: nil)
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
