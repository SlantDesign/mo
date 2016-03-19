//
//  PeripheralTests.swift
//  PeripheralTests
//
//  Created by travis on 2016-03-14.
//  Copyright © 2016 C4. All rights reserved.
//

import XCTest
@testable import Peripheral

class PeripheralTests: XCTestCase {

    func testSerialize() {
        let type = PacketType.General
        let message = PacketMessage.Bubbles
        let id = 17

        let packet = Packet(type: type, message: message, id: id, data: nil)
        let data = packet.serialize()
        var array = [Int8](count: data.length, repeatedValue: 0)
        data.getBytes(&array, length: data.length)

        let packetSize = Int(UnsafePointer<UInt32>(data.bytes).memory)
        XCTAssertEqual(packetSize, Packet.basePacketSize)

        XCTAssertEqual(array[4], type.rawValue)
        XCTAssertEqual(array[5], message.rawValue)

        let serializedId = Int(UnsafePointer<Int32>(data.bytes + 6).memory)
        XCTAssertEqual(serializedId, id)
    }

    func testRoundtrip() {
        let type = PacketType.Handshake
        let message = PacketMessage.None
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
