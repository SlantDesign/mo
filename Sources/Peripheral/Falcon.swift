//
//  Falcon.swift
//  MO
//
//  Created by travis on 2017-02-04.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import C4

class Falcon: Rocket {
    var preiginteMidship: SKEmitterNode?
    var ignitionRight: SKEmitterNode?

    override init() {
        super.init()
        path = CGPath.init(ellipseIn: CGRect(x: -50.0, y: -50.0, width: 100, height: 100), transform: nil)

        physicsBody = SKPhysicsBody(circleOfRadius: 50.0)
        physicsBody?.isDynamic = true

        preiginte = SKEmitterNode(fileNamed: "PreigniteFalcon")
        preiginteMidship = SKEmitterNode(fileNamed: "PreigniteFalconMidship")
        ignition = SKEmitterNode(fileNamed: "IgnitionFalcon")
        ignitionRight = SKEmitterNode(fileNamed: "IgnitionFalconRight")
        rocketFire = SKEmitterNode(fileNamed: "RocketFireFalcon")
        audio = AudioPlayer("falcon9.aiff")

        guard let rf = rocketFire else {
            return
        }

        rf.position = CGPoint(x: 0, y: -frame.height/2.0)
        rf.particleBirthRate = 0.0
        addChild(rf)

        preiginte?.particleBirthRate = 0.0
        preiginteMidship?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 0.0
        ignitionRight?.particleBirthRate = 0.0
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

        guard let pim = preiginteMidship else {
            print("Could not access preignite midship")
            return
        }
        pim.position = CGPoint(x: 0, y: frame.height * 0.66 + position.y)
        pim.particleBirthRate = 10.0

        if pim.parent == nil, parent != nil {
            parent?.addChild(pim)
        }

        guard let ig = ignition else {
            print("Could not access ignition")
            return
        }
        ig.position =  CGPoint(x: frame.width/4.0, y: -frame.height/2.0 + position.y)

        if ig.parent == nil, parent != nil {
            parent?.addChild(ig)
        }
        ig.particleBirthRate = 0.0

        guard let igr = ignitionRight else {
            print("Could not access ignitionRight")
            return
        }
        igr.position =  CGPoint(x: -frame.width/4.0, y: -frame.height/2.0 + position.y)

        if igr.parent == nil, parent != nil {
            parent?.addChild(igr)
        }
        igr.particleBirthRate = 0.0
    }

    override func ignite() {
        preiginte?.particleBirthRate = 0.0
        preiginteMidship?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 200.0
        ignitionRight?.particleBirthRate = 200.0
    }

    override func liftoff() {
        rocketFire?.particleBirthRate = 500.0

        let liftoffAnimation = SKAction.move(to: CGPoint(x:0, y: 3000), duration: 18.0)
        liftoffAnimation.timingMode = .easeIn
        run(liftoffAnimation)
    }

    func killIgnite() {
        ignition?.particleBirthRate = 0.0
        ignitionRight?.particleBirthRate = 0.0
    }

    override func reachedOrbit() {
        rocketFire?.particleBirthRate = 0.0
        run(SKAction.fadeAlpha(by: -1.0, duration: 0.0))
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

        wait(9.25) {
            self.ignite()
        }

        wait(10.0) {
            self.liftoff()
        }

        wait(12.5) {
            self.killIgnite()
        }

        wait(28.0) {
            self.reachedOrbit()
        }

        wait(32.0) {
            self.reveal()
        }
    }
}
