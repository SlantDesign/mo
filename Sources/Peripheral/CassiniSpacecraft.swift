//
//  CassiniSpacecraft.swift
//  MO
//
//  Created by travis on 2017-02-05.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import C4
import MO
import CocoaAsyncSocket

extension PacketType {
    static let cassini = PacketType(rawValue: 110000)
    static let cassini2 = PacketType(rawValue: 110001)
    static let cassiniShouldMove = PacketType(rawValue: 110002)
    static let cassini2ShouldMove = PacketType(rawValue: 110002)
}

class Cassini {
    static let primaryDevice = 15
    static let secondaryDevice = 16
}

//FIXME: Choose better arrangement
//FIXME: Increase levels for sun bursts
//FIXME: Increase reaction time for sun bursts
//FIXME: Improve physics on planets
//FIXME: More audio for ambient background
//FIXME: More audio for satellite movement

class CassiniSpaceCraft: SKSpriteNode {
    var burner: SKEmitterNode?
    var timer: C4.Timer?
    let turnSound = SKAudioNode(fileNamed:"satelliteTurn.aiff")
    var satelliteMoveSound: SKAudioNode? {
        willSet(newSound) {
            satelliteMoveSound?.run(SKAction.stop())
            satelliteMoveSound?.removeFromParent()

            guard let sound = newSound else {
                print("newSound == nil")
                return
            }
            sound.autoplayLooped = false
            addChild(sound)
        }
    }
    var cassiniIdentifier = Cassini.primaryDevice
    var packetType = PacketType.cassini
    var shouldMovePacketType = PacketType.cassiniShouldMove

    convenience init() {
        let t = SKTexture(image: #imageLiteral(resourceName: "cassini"))
        let c = UIColor.clear
        let s = CGSize(width: t.size().width*0.2, height: t.size().height * 0.2)
        self.init(texture: t, color: c, size: s)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        guard let b = SKEmitterNode(fileNamed: "CassiniRocketFire") else {
            print("Could not create burner.")
            return
        }
        b.position = CGPoint(x: -frame.width/4.0 - b.frame.width - 10.0, y: frame.height/8.0)
        b.particleBirthRate = 0.0
        addChild(b)
        burner = b

        isUserInteractionEnabled = true

        turnSound.autoplayLooped = false
        addChild(turnSound)
    }

    func start() {
        timer = C4.Timer(interval: 10.0) {
            self.broadcastMovement()
        }
        timer?.start()
    }

    func broadcastMovement() {
        timer?.stop()
        var position = randomPoint()
        let data = NSMutableData()
        data.append(&position, length: MemoryLayout<CGPoint>.size)
        let packet = Packet(type: packetType, id: cassiniIdentifier, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
        timer?.start()
    }

    func broadcastCassiniShouldMove() {
        let packet = Packet(type: shouldMovePacketType, id: cassiniIdentifier)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer?.stop()
        if cassiniIdentifier == Cassini.primaryDevice || cassiniIdentifier == Cassini.secondaryDevice {
            broadcastMovement()
        } else {
            broadcastCassiniShouldMove()
        }
    }

    func randomTargetIndex() -> Int {
        var index = random(min: 1, max: 29)
        if index == Stars.primaryDevice || index == Stars.secondaryDevice {
            index = randomTargetIndex()
        }
        return index
    }

    //FIXME: Calibrate to send out coordinates in universe space
    //FIXME: Remove targets for observatory screens
    func randomPoint() -> CGPoint {
        let index = randomTargetIndex()

        let x = CGFloat(index) * CGFloat(frameCanvasWidth) + CGFloat(frameCanvasWidth/2.0)
        let y = CGFloat(random01() * 824.0 - 412.0)
        let target = CGPoint(x: x, y: y)
        return target
    }

    func angle(to vector: Vector) -> Double {
        let a = Vector(x: Double(cos(zRotation)), y: Double(sin(zRotation)))
        let b = vector - Vector(position)

        var Θ = atan2(b.y, b.x) - atan2(a.y, a.x)
        if Θ > M_PI {
            Θ -= 2 * M_PI
        }

        return Θ
    }

    func rotate(to targetPoint: CGPoint) {
        let Θ = angle(to: Vector(targetPoint))
        run(rotate(by: Θ))
    }

    func rotateAndMove(to targetPoint: CGPoint) {
        removeAllActions()
        let Θ = angle(to: Vector(targetPoint))
        let rotation = rotate(by: Θ)
        rotation.timingMode = .easeInEaseOut

        let movement = move(to: targetPoint)
        movement.timingMode = .easeInEaseOut

        let startBurner = SKAction.customAction(withDuration: 0.0) { _, _ in
            self.burner?.particleBirthRate = 500.0
            self.satelliteMoveSound?.autoplayLooped = true
            self.satelliteMoveSound?.run(SKAction.repeat(SKAction.play(), count: 20))
        }

        let endBurner = SKAction.customAction(withDuration: 0) { _, _ in
            self.burner?.particleBirthRate = 0.0
            self.satelliteMoveSound?.run(SKAction.stop())
        }

        let rotateThenMove = SKAction.sequence([rotation, startBurner, movement, endBurner])
        run(rotateThenMove)
        turnSound.run(SKAction.play())
        if cassiniIdentifier == Cassini.primaryDevice ||
            cassiniIdentifier == Cassini.secondaryDevice {
            timer?.start()
        }
    }

    func rotate(by Θ: Double) -> SKAction {
        let duration = 1.29
        return SKAction.rotate(byAngle: CGFloat(Θ), duration: duration)
    }

    func move(to targetPoint: CGPoint) -> SKAction {
        let a = Vector(position)
        let b = Vector(targetPoint)
        let distance = (a - b).magnitude
        let duration = distance / frameCanvasWidth
        return SKAction.move(to: CGPoint(x: CGFloat(targetPoint.x), y: CGFloat(targetPoint.y)), duration: duration)
    }
}
