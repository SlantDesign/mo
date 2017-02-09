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

class CassiniSpaceCraft: SKSpriteNode {
    var burner: SKEmitterNode?
    var timer: C4.Timer?

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
        b.position = CGPoint(x: -frame.width/2.0 - b.frame.width, y: 0)
        b.particleBirthRate = 0.0
        addChild(b)
        burner = b

        isUserInteractionEnabled = true

        //FIXME: Change interval to suit the 28 devices
        if SocketManager.sharedManager.deviceID == Cassini.primaryDevice {
            timer = C4.Timer(interval: 5.0) {
                self.broadcastMovement()
            }
            timer?.start()
        }
    }

    func broadcastMovement() {
        var position = randomPoint()
        let data = NSMutableData()
        data.append(&position, length: MemoryLayout<CGPoint>.size)
        let packet = Packet(type: .cassini, id: SocketManager.sharedManager.deviceID, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer?.stop()
        timer?.start()
        rotateAndMove(to: randomPoint())
    }

    //FIXME: Calibrate to send out coordinates in universe space
    func randomPoint() -> CGPoint {
        guard let s = self.scene else {
            print("Could not access scene")
            return CGPoint()
        }

        let inset = s.frame.insetBy(dx: 0, dy: 50.0)

        let x = random(min: Int(inset.minX), max: Int(inset.maxX))
        let y = random(min: Int(inset.minY), max: Int(inset.maxY))
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
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

    func randomVector() -> Vector {
        guard let s = self.scene else {
            print("Could not access scene")
            return Vector()
        }

        let x = random(min: Int(s.frame.minX), max: Int(s.frame.maxX))
        let y = random(min: Int(s.frame.minY), max: Int(s.frame.maxY))
        return Vector(x: x, y: y)
    }

    func rotate(to targetPoint: CGPoint) {
        let Θ = angle(to: Vector(targetPoint))
        run(rotate(by: Θ))
    }

    func rotateAndMove(to targetPoint: CGPoint) {
        let Θ = angle(to: Vector(targetPoint))
        let rotation = rotate(by: Θ)
        rotation.timingMode = .easeInEaseOut
        let movement = move(to: targetPoint)
        movement.timingMode = .easeInEaseOut

        let startBurner = SKAction.customAction(withDuration: 0.0) { _, _ in
            self.burner?.particleBirthRate = 500.0
        }

        let endBurner = SKAction.customAction(withDuration: 0) { _, _ in
            self.burner?.particleBirthRate = 0.0
        }

        let rotateThenMove = SKAction.sequence([rotation, startBurner, movement, endBurner])
        run(rotateThenMove)
    }

    func rotate(by Θ: Double) -> SKAction {
        let duration = abs(Θ) / M_PI
        return SKAction.rotate(byAngle: CGFloat(Θ), duration: duration)
    }

    //FIXME: Calibrate duration to universe
    func move(to targetPoint: CGPoint) -> SKAction {
        let a = Vector(position)
        let b = Vector(targetPoint)
        let distance = (a - b).magnitude
        let duration = 2 * distance / frameCanvasWidth
        return SKAction.move(to: CGPoint(x: CGFloat(targetPoint.x), y: CGFloat(targetPoint.y)), duration: duration)
    }
}
