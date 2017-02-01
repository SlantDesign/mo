//
//  HelloMO.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import SpriteKit

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let planets = PacketType(rawValue: 600000)
}

class Planets: UniverseController, GCDAsyncSocketDelegate {
    let socketManager = SocketManager.sharedManager

    override func setup() {
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.planets:
            break
        default:
            break
        }
    }

    //This is how you send a packet, with no data
    func send(type: PacketType) {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: type, id: deviceId)
        socketManager.broadcastPacket(packet)
    }
}
