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

    override func didMove(to view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 10.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)

        let ball = SKShapeNode(circleOfRadius: 50.0)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 50.0)
        ball.physicsBody?.isDynamic = true
        addChild(ball)
        self.rocket = ball
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.triggerImpulses()
    }

    var timer: C4.Timer?

    let duration = 4.0
    override func update(_ currentTime: TimeInterval) {
        if launch {
            if launchTime == 0.0 {
                launchTime = currentTime
            }

            let force = powf(Float(currentTime-launchTime)/Float(duration), 5.0)
            self.rocket?.physicsBody?.applyForce(CGVector(dx: 0, dy: 2400.0 * CGFloat(force)))
            if currentTime - launchTime > duration {
                launch = false
                launchTime = 0.0
                print("done")
            }
        }
    }

    func triggerImpulses() {
        launch = true
    }
}
