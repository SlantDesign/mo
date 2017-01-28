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

class AsteroidBeltScene: SKScene {
    private var nodes: [SKSpriteNode]?// = [SKSpriteNode]()
    var asteroidBeltDelegate: AsteroidBeltDelegate?

    override func didMove(to view: SKView) {
        let w = 132
        nodes = [SKSpriteNode]()
        for i in 0...3 {
            let node = SKSpriteNode(imageNamed: "Asteroid_0\(i)")
            node.size = CGSize(width: w, height: w)
            node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: w))
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.friction = 0.0
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 1)))
            node.run(SKAction.sequence([SKAction.move(by: CGVector(dx: CGFloat(frameCanvasWidth*2), dy: 1224), duration: 10),
                                        SKAction.removeFromParent()]))
            nodes?.append(node)
        }
    }

    func createAsteroid(point: CGPoint, tag: Int) {
        guard let n = self.nodes?[tag % 4].copy() as! SKSpriteNode? else {
            return
        }

        for child in self.children {
            if child.name == "\(tag)" {
                print("found identical tag, aborting")
                return
            }
        }

        n.name = "\(tag)"
        n.position = point
        n.physicsBody?.affectedByGravity = false
        self.addChild(n)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let ns = nodes(at: t.location(in: self))
            for n in ns {
                guard let name = n.name else {
                    print("Couldn't extract name from asteroid")
                    return
                }
                guard let tag = Int(name) else {
                    print("Couldn't convert name to Int")
                    return
                }
                asteroidBeltDelegate?.explodeAsteroid(tag: tag)
            }
        }
    }

    func explodeAsteroid(tag: Int) {
        for asteroid in self.children {
            print("\(asteroid.name) <> \(tag)")
            if asteroid.name == "\(tag)" {
                asteroid.removeFromParent()
                let explode = SKEmitterNode(fileNamed: "Explode")!
                explode.position = asteroid.position
                self.addChild(explode)
                explode.run(SKAction.move(by: CGVector(dx: 2400, dy: 2200), duration: 10))
                explode.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5),
                                               SKAction.removeFromParent()]))
            }
            break
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
