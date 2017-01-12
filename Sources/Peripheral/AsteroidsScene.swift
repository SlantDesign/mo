//
//  GameScene.swift
//  AsteroidSim
//
//  Created by travis on 2017-01-11.
//  Copyright © 2017 C4. All rights reserved.
//

import SpriteKit
import GameplayKit
import SceneKit
import C4

class AsteroidsScene: SKScene {
    private var node: SKSpriteNode?

    override func didMove(to view: SKView) {
        let w = 100
        self.node = SKSpriteNode(imageNamed: "asteroid")
        self.node?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: w))
        self.node?.physicsBody?.affectedByGravity = false
        self.node?.physicsBody?.friction = 0.0

        if let node = self.node {
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 1)))
            node.run(SKAction.sequence([SKAction.move(by: CGVector(dx: 1200, dy: 1200), duration: 10),
                                        SKAction.removeFromParent()]))
        }

    }



    func createAsteroid(point: Point) {
        guard let n = self.node?.copy() as! SKSpriteNode? else {
            return
        }

        n.position = CGPoint(point)
        n.physicsBody?.affectedByGravity = false
        self.addChild(n)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let ns = nodes(at: t.location(in: self))
            for n in ns {
                n.removeFromParent()
                let explode = SKEmitterNode(fileNamed: "Explode")!
                explode.position = n.position
                self.addChild(explode)
                explode.run(SKAction.move(by: CGVector(dx: 1200, dy: 1200), duration: 10))
                explode.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5),
                                               SKAction.removeFromParent()]))
            }
        }

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
