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
    static let voyager = PacketType(rawValue: 130000)
    static let voyagerShouldMove = PacketType(rawValue: 130001)
}

class Voyager {
    static let primaryDevice = 28
}

class VoyagerSpaceCraft: SKSpriteNode {
    var burner: SKEmitterNode?
    var timer: C4.Timer?
    let turnSound = SKAudioNode(fileNamed:"satelliteTurn.aiff")
    let satelliteMoveSound = SKAudioNode(fileNamed: "satelliteResponse3.aiff")
    var moving = false

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

        satelliteMoveSound.autoplayLooped = true
    }

    func start() {
        timer = C4.Timer(interval: 60.0) {
            self.broadcastMovement()
        }
        timer?.start()
    }

    func broadcastMovement() {
        timer?.stop()
        var position = randomPoint()
        let data = NSMutableData()
        data.append(&position, length: MemoryLayout<CGPoint>.size)
        let packet = Packet(type: PacketType.voyager, id: SocketManager.sharedManager.deviceID, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
        timer?.start()
    }

    func broadcastCassiniShouldMove() {
        let packet = Packet(type: PacketType.voyagerShouldMove, id: SocketManager.sharedManager.deviceID)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !moving {
            timer?.stop()
            if SocketManager.sharedManager.deviceID == Voyager.primaryDevice {
                broadcastMovement()
            } else {
                broadcastCassiniShouldMove()
            }
        }
    }

    func randomTargetIndex() -> Int {
        var index = random(min: 1, max: 29)
        if index == Stars.primaryDevice || index == Stars.secondaryDevice {
            index = randomTargetIndex()
        }
        return index
    }

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
            self.moving = true
            self.burner?.particleBirthRate = 500.0
            if self.satelliteMoveSound.parent != nil {
                self.satelliteMoveSound.removeFromParent()
            }
            self.addChild(self.satelliteMoveSound)
        }

        let endBurner = SKAction.customAction(withDuration: 0) { _, _ in
            self.burner?.particleBirthRate = 0.0
            if self.satelliteMoveSound.parent != nil {
                self.satelliteMoveSound.removeFromParent()
            }
            self.moving = false
        }

        let rotateThenMove = SKAction.sequence([rotation, startBurner, movement, endBurner])
        run(rotateThenMove)
        turnSound.run(SKAction.play())
        if SocketManager.sharedManager.deviceID == Voyager.primaryDevice {
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
