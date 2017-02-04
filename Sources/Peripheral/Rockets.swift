//
//  Rockets.swift
//  MO
//
//  Created by travis on 2017-02-03.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import SpriteKit

extension PacketType {
    static let rockets = PacketType(rawValue: 900000)
}

class Rockets: UniverseController, GCDAsyncSocketDelegate {

    override func setup() {
        
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.rockets:
            break
        default:
            break
        }
    }
}
