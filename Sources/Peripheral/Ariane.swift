//
//  Ariane.swift
//  MO
//
//  Created by travis on 2017-02-04.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation

import Foundation
import SpriteKit
import C4

class Ariane: Rocket {
    var preiginteRight: SKEmitterNode?
    var ignitionRight: SKEmitterNode?
    var ignitionFire: SKEmitterNode?
    var ignitionFireRight: SKEmitterNode?
    var rocketFireRight: SKEmitterNode?

    var boosterOffset: CGFloat = 25.0
    override init() {
        super.init()
        path = CGPath.init(ellipseIn: CGRect(x: -50.0, y: -50.0, width: 100, height: 100), transform: nil)

        physicsBody = SKPhysicsBody(circleOfRadius: 50.0)
        physicsBody?.isDynamic = true

        preiginte = SKEmitterNode(fileNamed: "PreigniteAriane")
        ignition = SKEmitterNode(fileNamed: "IgnitionSmokeAriane")
        ignitionFire = SKEmitterNode(fileNamed: "IgnitionFireAriane")
        rocketFire = SKEmitterNode(fileNamed: "RocketFireAriane")

        preiginteRight = SKEmitterNode(fileNamed: "PreigniteAriane")
        ignitionRight = SKEmitterNode(fileNamed: "IgnitionSmokeArianeRight")
        ignitionFireRight = SKEmitterNode(fileNamed: "IgnitionFireAriane")
        rocketFireRight = SKEmitterNode(fileNamed: "RocketFireAriane")

        audio = AudioPlayer("ariane.aiff")

        guard let rf = rocketFire else {
            return
        }

        rf.position = CGPoint(x: -boosterOffset, y: -frame.height/2.0)
        rf.particleBirthRate = 0.0
        addChild(rf)

        guard let rfr = rocketFireRight else {
            return
        }

        rfr.position = CGPoint(x: boosterOffset, y: -frame.height/2.0)
        rfr.particleBirthRate = 0.0
        addChild(rfr)

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
        pi.position = CGPoint(x: -boosterOffset, y: -frame.height/2.0 + position.y)
        pi.particleBirthRate = 30.0

        if pi.parent == nil, parent != nil {
            parent?.addChild(pi)
        }

        guard let pir = preiginteRight else {
            print("Could not access preignite")
            return
        }
        pir.position = CGPoint(x: boosterOffset, y: -frame.height/2.0 + position.y)
        pir.particleBirthRate = 30.0

        if pir.parent == nil, parent != nil {
            parent?.addChild(pir)
        }

        guard let ig = ignition else {
            print("Could not access ignition")
            return
        }
        ig.position =  CGPoint(x: -boosterOffset, y: -frame.height/2.0 + position.y)

        if ig.parent == nil, parent != nil {
            parent?.addChild(ig)
        }
        ig.particleBirthRate = 0.0

        guard let igr = ignitionRight else {
            print("Could not access ignition")
            return
        }
        igr.position =  CGPoint(x: boosterOffset, y: -frame.height/2.0 + position.y)

        if igr.parent == nil, parent != nil {
            parent?.addChild(igr)
        }
        igr.particleBirthRate = 0.0

        guard let igf = ignitionFire else {
            print("Could not access ignition fire")
            return
        }
        igf.position =  ig.position

        if igf.parent == nil, parent != nil {
            parent?.addChild(igf)
        }
        igf.particleBirthRate = 0.0

        guard let igfr = ignitionFireRight else {
            print("Could not access ignition fire")
            return
        }
        igfr.position =  igr.position

        if igfr.parent == nil, parent != nil {
            parent?.addChild(igfr)
        }
        igfr.particleBirthRate = 0.0
    }

    override func ignite() {
        preiginte?.particleBirthRate = 0.0
        ignition?.particleBirthRate = 150.0
        ignitionFire?.particleBirthRate = 400.0

        preiginteRight?.particleBirthRate = 0.0
        ignitionRight?.particleBirthRate = 150.0
        ignitionFireRight?.particleBirthRate = 400.0

    }

    override func liftoff() {
        ignition?.particleBirthRate = 0.0
        ignitionFire?.particleBirthRate = 0.0
        rocketFire?.particleBirthRate = 500.0

        ignitionRight?.particleBirthRate = 0.0
        ignitionFireRight?.particleBirthRate = 0.0
        rocketFireRight?.particleBirthRate = 200.0

        let liftoffAnimation = SKAction.move(to: CGPoint(x:0, y: 2400), duration: 10.0)
        liftoffAnimation.timingMode = .easeIn
        run(liftoffAnimation)
    }

    override func reachedOrbit() {
        rocketFire?.particleBirthRate = 0.0
        rocketFireRight?.particleBirthRate = 0.0
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

        wait(14.0) {
            self.ignite()
        }

        wait(20.0) {
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
