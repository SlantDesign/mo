//
//  Planet.swift
//  MO
//
//  Created by travis on 2017-02-12.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import MO
import CocoaAsyncSocket
import C4

class Planet: SKSpriteNode {
    public convenience init(imageNamed name: String) {
        let t = SKTexture(imageNamed: name)
        self.init(texture: t, color: UIColor.clear, size: t.size())
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func randomDirection() -> CGFloat {
        return random(below: 2) == 0 ? -1.0 : 1.0
    }

    func randomVector() -> CGVector {
        let x = CGFloat(random01()) * 200.0 + 200.0
        let y = CGFloat(random01()) * 200.0 + 200.0
        return CGVector(dx: x * randomDirection(), dy: y * randomDirection())
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let t = [UITouch](touches)
        let touch = t[0]

        guard let scene = self.scene else {
            return
        }

        var touchPosition = touch.location(in: scene)

        guard let n = name else {
            print("Couldn't get current planet name")
            return
        }
        let data = NSMutableData()
        var index = SolarSystem.planetNames.index(of: n)
        data.append(&index, length: MemoryLayout<Int>.size)
        data.append(&touchPosition, length: MemoryLayout<CGVector>.size)
        let packet = Packet(type: .planetPosition, id: SocketManager.sharedManager.deviceID, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = self.scene else {
            print("Couldn't get scene")
            return
        }
        self.physicsBody?.isDynamic = true
        let t = [UITouch](touches)
        let touch = t[0]
        let touchPosition = touch.location(in: scene)
        //let prev = touch.previousLocation(in: scene)
        var velocity = CGVector(dx: (touchPosition.x - position.x) * 60.0, dy: (touchPosition.y - position.y) * 60.0)

        guard let n = name else {
            print("Couldn't get current planet name")
            return
        }
        let data = NSMutableData()
        var index = SolarSystem.planetNames.index(of: n)
        data.append(&index, length: MemoryLayout<Int>.size)
        data.append(&velocity, length: MemoryLayout<CGVector>.size)
        let packet = Packet(type: .planetVelocity, id: SocketManager.sharedManager.deviceID, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let n = name else {
            print("Couldn't get current planet name")
            return
        }
        var data = Data()
        let index = SolarSystem.planetNames.index(of: n)
        data.append(index)
        data.append(false)
        let packet = Packet(type: .planetIsDynamic, id: SocketManager.sharedManager.deviceID, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //
    //        guard let n = name else {
    //            print("Couldn't get name of planet")
    //            return
    //        }
    //
    //        let data = NSMutableData()
    //        var index = SolarSystem.planetNames.index(of: n)
    //        data.append(&index, length: MemoryLayout<Int>.size)
    //        var v = randomVector()
    //        data.append(&v, length: MemoryLayout<CGVector>.size)
    //
    //        let packet = Packet(type: .planet, id: SocketManager.sharedManager.deviceID, payload: data as Data)
    //        SocketManager.sharedManager.broadcastPacket(packet)
    //    }
}
