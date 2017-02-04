//
//  RocketsScene.swift
//  MO
//
//  Created by travis on 2017-02-03.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import SpriteKit

class RocketsScene: SKScene {
    var rocket: SKShapeNode?
    var launch = false
    var launchTime: TimeInterval = 0.0
    let smoke = RocketSmoke(fileNamed: "Smoke")
    let rocketSmoke = RocketSmoke(fileNamed: "RocketSmoke")

    override func didMove(to view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 80.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)

        let ball = SKShapeNode(circleOfRadius: 50.0)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 50.0)
        ball.physicsBody?.isDynamic = true
        ball.position = CGPoint(x: 0, y: -view.frame.height/3.0)
        addChild(ball)
        self.rocket = ball

        rocketSmoke?.position = CGPoint(x: 0, y: -ball.frame.height/2.0)
        rocketSmoke?.particleBirthRate = 0.0
        rocket?.addChild(rocketSmoke!)

        smoke?.particleBirthRate = 0.0
    }


//    - (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
//    {
//    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
//    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
//
//    //do some view specific tweaks
//    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
//    emitterNode.particlePositionRange = CGVectorMake(self.size.width+100, self.size.height);
//
//    return emitterNode;
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.triggerImpulses()
    }

    var timer: C4.Timer?

    let duration = 6.0
    var step = 0
    override func update(_ currentTime: TimeInterval) {
        if launch {
            if launchTime == 0.0 {
                step = 0
                launchTime = currentTime

                if smoke?.parent == nil {
                    smoke?.position = CGPoint(x: 0, y: -rocket!.frame.height/2.0 + rocket!.position.y)
                    smoke?.removeFromParent()
                    addChild(smoke!)
                }

                if let s = smoke {
                    s.particleBirthRate = 10
                    s.particlePositionRange = CGVector(dx: 0, dy: 0)
                    s.particleLifetime = 10
                    s.emissionAngle = -90
                    s.emissionAngleRange = 0
                    s.particleSpeed = 20
                    s.particleAlpha = 0.5
                    s.particleAlphaRange = 0.3
                    s.particleAlphaSpeed = -0.15
                    s.particleScale = 0.4
                    s.particleScaleRange = 0.3
                    s.particleScaleSpeed = 0.5
                }
            }

            if floor(currentTime-launchTime) > 1.0 && step == 0 {
                if let s = smoke {
                    s.particleBirthRate = 150
                    s.particlePositionRange = CGVector(dx: 80, dy: 0)
                    s.particleLifetime = 20
                    s.emissionAngle = -90
                    s.emissionAngleRange = 180
                    s.particleSpeed = 20
                    s.particleSpeedRange = 60
                    s.xAcceleration = 0
                    s.yAcceleration = 0
                    s.particleAlpha = 0.5
                    s.particleAlphaRange = 0.3
                    s.particleAlphaSpeed = -0.15
                    s.particleScale = 0.5
                    s.particleScaleRange = 0.3
                    s.particleScaleSpeed = 0.5
                }
                step += 1
            } else if floor(currentTime-launchTime) > 2.0 && step == 1 {
                if let s = smoke {
                    s.particleBirthRate = 0
                }
                if let rs = rocketSmoke {
                    rs.particleBirthRate = 50.0
                }
            }

            let dt = CGFloat(currentTime-launchTime) / CGFloat(duration)
            let force = -(CGFloat(sqrt(1.0 - dt * dt)) - 1.0)

            //            let force = powf(Float(currentTime-launchTime)/Float(duration), 3.0)
            self.rocket?.physicsBody?.applyForce(CGVector(dx: 0, dy: 2000.0 * force))
            if currentTime - launchTime > duration {
                launch = false
                launchTime = 0.0
                step = 0
                rocketSmoke?.particleBirthRate = 0.0
            }
        }
    }

    func triggerImpulses() {
        launch = true
    }
}

class RocketSmoke: SKEmitterNode {
    /*
     Start Smoke
     birthrate = 10
     position range x = 0
     lifetime = 10
     angle = -90
     speed = 20
     alpha = 0.5 range(0.3) speed(-0.15)
     range = 0.3
     acceleration 0 0
     speed = -0.15
     scale = 0.4 range(0.3) speed(0.5)
     */
    func preignite() {
        particleBirthRate = 10
        particlePositionRange = CGVector(dx: 0, dy: 0)
        particleLifetime = 10
        emissionAngle = -90
        emissionAngleRange = 0
        particleSpeed = 20
        particleAlpha = 0.5
        particleAlphaRange = 0.3
        particleAlphaSpeed = -0.15
        particleScale = 0.4
        particleScaleRange = 0.3
        particleScaleSpeed = 0.5
    }

    /*
     ignition Smoke
     birthrate = 150
     lifetime = 20
     position range x = 80
     angle = -90 range 180
     speed = 20 range 60
     acceleration 0 0
     alpha = 0.5 range(0.3) speed(-0.15)
     scale = 0.5 range(0.3) speed(0.5)
     */
    func ignition() {
        particleBirthRate = 150
        particlePositionRange = CGVector(dx: 80, dy: 0)
        particleLifetime = 20
        emissionAngle = -90
        emissionAngleRange = 180
        particleSpeed = 20
        particleSpeedRange = 60
        xAcceleration = 0
        yAcceleration = 0
        particleAlpha = 0.5
        particleAlphaRange = 0.3
        particleAlphaSpeed = -0.15
        particleScale = 0.5
        particleScaleRange = 0.3
        particleScaleSpeed = 0.5
    }

    /*
     liftoff Smoke
     birthrate = 50
     lifetime = 15 range 5
     position range x = 0
     angle = -90 range 0
     speed = 30 range 20
     acceleration 0 -50
     alpha = 0.25 range(0.15) speed(-0.15)
     scale = 0.25 range(0.15) speed(0.8)
     */
    func liftoff() {
        particleBirthRate = 50
        particlePositionRange = CGVector(dx: 80, dy: 0)
        particleLifetime = 15
        particleLifetimeRange = 5
        emissionAngle = -90
        emissionAngleRange = 0
        particleSpeed = 30
        particleSpeedRange = 20
        xAcceleration = 0
        yAcceleration = -50
        particleAlpha = 0.25
        particleAlphaRange = 0.15
        particleAlphaSpeed = -0.15
        particleScale = 0.25
        particleScaleRange = 0.15
        particleScaleSpeed = 0.8
    }
}
