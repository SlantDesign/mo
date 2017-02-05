//
//  Soyuz.swift
//  MO
//
//  Created by travis on 2017-02-04.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import C4

class Soyuz: Rocket {
    var ignitionFire: SKEmitterNode?

    override init() {
        super.init()
        path = CGPath.init(ellipseIn: CGRect(x: -50.0, y: -50.0, width: 100, height: 100), transform: nil)

        physicsBody = SKPhysicsBody(circleOfRadius: 50.0)
        physicsBody?.isDynamic = true

        preiginte = SKEmitterNode(fileNamed: "PreigniteSoyuz")
        ignition = SKEmitterNode(fileNamed: "IgnitionSmokeSoyuz")
        ignitionFire = SKEmitterNode(fileNamed: "IgnitionFireSoyuz")
        rocketFire = SKEmitterNode(fileNamed: "RocketFireSoyuz")
        audio = AudioPlayer("soyuz.aiff")

        guard let rf = rocketFire else {
            return
        }

        rf.position = CGPoint(x: 0, y: -frame.height/2.0)
        rf.particleBirthRate = 0.0
        addChild(rf)

        preiginte?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 0.0
        ignitionFire?.particleBirthRate = 0.0
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
        pi.particleBirthRate = 30.0

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

        guard let igf = ignitionFire else {
            print("Could not access ignition fire")
            return
        }
        igf.position =  ig.position

        if igf.parent == nil, parent != nil {
            parent?.addChild(igf)
        }
        igf.particleBirthRate = 0.0
    }

    override func ignite() {
        preiginte?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 150.0
        ignitionFire?.particleBirthRate = 300.0
    }

    override func liftoff() {
        ignition?.particleBirthRate = 0.0
        ignitionFire?.particleBirthRate = 0.0
        rocketFire?.particleBirthRate = 500.0

        let liftoffAnimation = SKAction.move(to: CGPoint(x:0, y: 2000), duration: 10.0)
        liftoffAnimation.timingMode = .easeIn
        run(liftoffAnimation)
    }

    override func reachedOrbit() {
        rocketFire?.particleBirthRate = 0.0
        run(SKAction.fadeAlpha(by: -1.0, duration: 0.0))
        physicsBody?.isDynamic = true
    }

    override func reveal() {
        run(SKAction.fadeAlpha(by: 1.0, duration: 1.0))
    }

    override func launch() {
        launching = true
        preignite()
        audio?.play()

        wait(6.0) {
            self.ignite()
        }

        wait(18.0) {
            self.liftoff()
        }

        wait(28.0) {
            self.reachedOrbit()
        }

        wait(32.0) {
            self.reveal()
        }
    }
}
