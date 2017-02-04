//
//  SolarSystem.swift
//  MO
//
//  Created by travis on 2017-02-03.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import CocoaAsyncSocket
import C4
import MO

class SolarSystem: UniverseController, GCDAsyncSocketDelegate {
    static let primaryDevice = 17
    static let planetNames: [String] = ["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]
    var solarSystemView = SKView()
    var solarSystemScene: SolarSystemScene?

    override func setup() {
        solarSystemView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(solarSystemView)

        guard let scene = SolarSystemScene(fileNamed: "SolarSystemScene") else {
            print("Could not load SolarSystemScene")
            return
        }

        scene.scaleMode = .aspectFill
        solarSystemView.presentScene(scene)
        solarSystemScene = scene

        solarSystemView.ignoresSiblingOrder = false
        solarSystemView.showsFPS = true
        solarSystemView.showsNodeCount = true
    }

    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.planet:
            guard let payload = packet.payload else {
                print("Couldn't extract payload")
                return
            }

            let nameIndex = payload.extract(Int.self, at: 0)
            let name = SolarSystem.planetNames[nameIndex]
            let impulse = payload.extract(CGVector.self, at: MemoryLayout<Int>.size)
            solarSystemScene?.apply(impulse: impulse, to: name)
        case PacketType.planetVelocity:
            guard let payload = packet.payload else {
                print("Couldn't extract payload")
                return
            }

            let nameIndex = payload.extract(Int.self, at: 0)
            let name = SolarSystem.planetNames[nameIndex]
            let velocity = payload.extract(CGVector.self, at: MemoryLayout<Int>.size)
            solarSystemScene?.set(velocity: velocity, for: name)
        case PacketType.planetPosition:
            guard let payload = packet.payload else {
                print("Couldn't extract payload")
                return
            }

            let nameIndex = payload.extract(Int.self, at: 0)
            let name = SolarSystem.planetNames[nameIndex]
            var position = payload.extract(CGPoint.self, at: MemoryLayout<Int>.size)
            let offset = CGFloat(packet.id - SocketManager.sharedManager.deviceID) * CGFloat(frameCanvasWidth)
            position.x += offset
            solarSystemScene?.set(position: position, for: name)
        case PacketType.planetIsDynamic:
            guard let payload = packet.payload else {
                print("Couldn't extract payload")
                return
            }

            let nameIndex = payload.extract(Int.self, at: 0)
            let name = SolarSystem.planetNames[nameIndex]
            let isDynamic = payload.extract(Bool.self, at: MemoryLayout<Int>.size)
            solarSystemScene?.set(isDynamic: isDynamic, for: name)
        default:
            break
        }
    }
}
