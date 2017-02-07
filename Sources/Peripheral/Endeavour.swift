//
//  Endeavour.swift
//  MO
//
//  Created by travis on 2017-02-04.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import C4

class Endeavour: Rocket {
    let restingPosition = CGPoint(x: 0, y: -284.049377441406)
    convenience init() {
        let t = SKTexture(image: #imageLiteral(resourceName: "Endeavor"))
        let c = UIColor.clear
        let s = CGSize(width: t.size().width * 0.2, height: t.size().height * 0.2)
        self.init(texture: t, color: c, size: s)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)

        position = restingPosition
        preiginte = SKEmitterNode(fileNamed: "PreigniteEndeavour")
        ignition = SKEmitterNode(fileNamed: "IgnitionEndeavour")
        rocketFire = SKEmitterNode(fileNamed: "RocketFireEndeavour")
        audio = AudioPlayer("endeavour.aiff")

        guard let rf = rocketFire else {
            return
        }

        rf.position = CGPoint(x: 0, y: -frame.height/2.0)
        rf.particleBirthRate = 0.0
        addChild(rf)

        preiginte?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preignite() {
        physicsBody?.isDynamic = false

        guard let pi = preiginte else {
            print("Could not access preignite")
            return
        }
        pi.position = CGPoint(x: 0, y: -frame.height/2.0 + position.y)
        pi.particleBirthRate = 10.0

        if pi.parent == nil, parent != nil {
            parent?.addChild(pi)
        }

        guard let ig = ignition else {
            print("Could not access ignition")
            return
        }
        ig.position =  CGPoint(x: 0, y: -frame.height/2.0 + position.y)

        if ig.parent == nil, parent != nil {
            parent?.addChild(ig)
        }
        ig.particleBirthRate = 0.0
    }

    override func ignite() {
        preiginte?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 150.0
    }

    override func liftoff() {
        ignition?.particleBirthRate = 0.0
        rocketFire?.particleBirthRate = 50.0

        let liftoffAnimation = SKAction.move(to: CGPoint(x:0, y: 3000), duration: 10.0)
        liftoffAnimation.timingMode = .easeIn
        run(liftoffAnimation)
    }

    override func reachedOrbit() {
        rocketFire?.particleBirthRate = 0.0
        run(SKAction.fadeAlpha(by: -1.0, duration: 0.0))
        run(SKAction.move(to: restingPosition, duration: 0.0))
        physicsBody?.isDynamic = true
    }

    override func reveal() {
        run(SKAction.fadeAlpha(by: 1.0, duration: 1.0))
        launching = false
    }

    override func launch() {
        launching = true
        preignite()
        audio?.play()

        wait(5.0) {
            self.ignite()
        }

        wait(11.0) {
            self.liftoff()
        }

        wait(21.0) {
            self.reachedOrbit()
        }

        wait(26.0) {
            self.reveal()
        }
    }
}
