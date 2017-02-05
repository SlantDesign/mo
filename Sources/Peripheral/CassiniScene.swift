//
//  CassiniScene.swift
//  MO
//
//  Created by travis on 2017-02-04.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import C4

class CassiniScene: SKScene {
    let cassini = CassiniSpaceCraft()

    override func didMove(to view: SKView) {
        addChild(cassini)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            cassini.rotate(to: t.location(in: self))
        }
    }
}

class CassiniSpaceCraft: SKShapeNode {
    var burner: SKEmitterNode?

    override init() {
        super.init()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -25, y: -25))
        path.addLine(to: CGPoint(x: 25, y: -25))
        path.addLine(to: CGPoint(x: 50, y: 0))
        path.addLine(to: CGPoint(x: 25, y: 25))
        path.addLine(to: CGPoint(x: -25, y: 25))
        path.addLine(to: CGPoint(x: -25, y: -25))
        path.addLine(to: CGPoint(x: 25, y: 25))
        path.addLine(to: CGPoint(x: 25, y: -25))
        path.addLine(to: CGPoint(x: -25, y: 25))

        self.path = path

        guard let b = SKEmitterNode(fileNamed: "CassiniRocketFire") else {
            print("Could not create burner.")
            return
        }
        b.position = CGPoint(x: -frame.width/2.0 - b.frame.width, y: 0)
        addChild(b)
        burner = b

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var target = randomVector()
        if let t = touches.first, let s = scene {
            target = Vector(t.location(in: s))
        }
        let Θ = angle(to: target)
        rotate(by: Θ)
    }

    func angle(to vector: Vector) -> CGFloat {
        let a = Vector(position) + Vector(x: Double(cos(zRotation)), y: Double(sin(zRotation)))
        let b = Vector(position)
        let c = vector

        let Θ = a.angleTo(c, basedOn: b) //FIXME: GET THIS DOING NEGATIVES

        return CGFloat(Θ)
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
        rotate(by: Θ)
    }

    func rotate(by targetAngle: CGFloat) {
        let rotate = SKAction.rotate(byAngle: targetAngle, duration: 1.0)
        run(rotate)
    }

    func move(to: CGPoint) {

    }
}
