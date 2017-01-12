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
    var asteroidsDelegate: AsteroidsDelegate?

    override func didMove(to view: SKView) {
        let w = 100
        self.node = SKSpriteNode(imageNamed: "asteroid")
        self.node?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: w))
        self.node?.physicsBody?.affectedByGravity = false
        self.node?.physicsBody?.friction = 0.0

        if let node = self.node {
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 1)))
            node.run(SKAction.sequence([SKAction.move(by: CGVector(dx: CGFloat(frameCanvasWidth*2), dy: 1224), duration: 10),
                                        SKAction.removeFromParent()]))
        }
    }

    func createAsteroid(point: CGPoint, tag: Int) {
        print("---")
        print(tag)
       guard let n = self.node?.copy() as! SKSpriteNode? else {
            return
        }

        for n in self.children {
            if n.name == "\(tag)" {
                return
            }
        }

        n.name = "\(tag)"
        n.position = point
        n.physicsBody?.affectedByGravity = false

        switch tag % 5 {
        case 0:
            n.color = UIColor.red
        case 1:
            n.color = UIColor.green
        case 2:
            n.color = UIColor.blue
        case 3:
            n.color = UIColor.yellow
        case 4:
            n.color = UIColor.orange
        default:
            n.color = UIColor.purple
            break
        }
        n.run(SKAction.colorize(with: n.color, colorBlendFactor: 1.0, duration: 0))
        self.addChild(n)
        print(n.name)
        print("---")
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
                asteroidsDelegate?.explodeAsteroid(tag: tag)
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
