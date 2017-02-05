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
    static let primaryDevice = 17
    let socketManager = SocketManager.sharedManager
    let rocketsView = SKView()
    var rocketsScene: RocketsScene?

    override func setup() {
        rocketsView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(rocketsView)

        guard let scene = RocketsScene(fileNamed: "RocketsScene") else {
            print("Could not load RocketsScene")
            return
        }
        scene.scaleMode = .aspectFill
        rocketsView.presentScene(scene)
        rocketsScene = scene

        rocketsView.ignoresSiblingOrder = false
        rocketsView.showsFPS = true
        rocketsView.showsNodeCount = true

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
