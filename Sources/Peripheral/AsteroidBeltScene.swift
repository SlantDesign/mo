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
    private var copyableAsteroids: [Asteroid]?
    private var cometAuraFrames: [SKTexture]?
    private var cometAura: SKSpriteNode?
    private let cometAuraAtlas = SKTextureAtlas(named: "comet_aura")

    override func didMove(to view: SKView) {
        cometAuraFrames = [SKTexture]()
        for i in 0..<cometAuraAtlas.textureNames.count/2 {
            let texture = cometAuraAtlas.textureNamed("comet_aura_\(i)")
            cometAuraFrames?.append(texture)
        }

        copyableAsteroids = [Asteroid]()
        for i in 0...3 {
            let asteroid = Asteroid(imageNamed: "Asteroid_0\(i)")
            asteroid.size = CGSize(width: 132, height: 132)
            asteroid.physicsBody = SKPhysicsBody(rectangleOf: Asteroid.physicsBodySize)
            asteroid.physicsBody?.affectedByGravity = false
            asteroid.physicsBody?.friction = 0.0
            copyableAsteroids?.append(asteroid)
        }
    }

    func findAsteroid(identifier: Int) -> Asteroid? {
        for child in children {
            if child.name == "\(identifier)" {
                if let asteroid = child as? Asteroid {
                    return asteroid
                }
            }
        }
        return nil
    }

    func removeAsteroidAddComet(identifier: Int, position: CGPoint) {
        createComet(identifier: identifier, position: position)

        guard let asteroid = findAsteroid(identifier: identifier) else {
            return
        }
        asteroid.removeFromParent()
    }

    func createComet(identifier: Int, position: CGPoint) {
        guard let comet = self.copyableAsteroids?[identifier % 4].copy() as! Asteroid? else {
            print("Couldn't create a copy of the asteroid")
            return
        }

        comet.isUserInteractionEnabled = false
        comet.position = position
        comet.physicsBody = nil
        addAura(to: comet)
        comet.run(moveComet())
        self.addChild(comet)
    }

    func moveComet() -> SKAction {
        let movement = SKAction.move(by: CGVector(dx: CGFloat(frameCanvasWidth * 4.0), dy: 0.0), duration: 5.0)
        let scale = SKAction.scale(by: 0.25, duration: 1.5)
        let fade = SKAction.fadeOut(withDuration: 1.5)
        let wait = SKAction.wait(forDuration: movement.duration-1.5)
        let fadeScale = SKAction.group([fade, scale])
        let waitFadeScale = SKAction.sequence([wait, fadeScale, SKAction.removeFromParent()])
        return SKAction.group([movement, waitFadeScale])
    }

    func addAura(to asteroid: Asteroid) {
        guard let texture = cometAuraFrames?[0] else {
            print("could not extract a texture")
            return
        }

        let aura = SKSpriteNode(texture: texture)
        aura.anchorPoint = CGPoint(x: 0.85, y: 0.45)

        guard let frames = cometAuraFrames else {
            print("Frames weren't available")
            return
        }

        let anim = SKAction.animate(with: frames, timePerFrame: 1.0/12.0, resize: false, restore: true)
        let repeatAnim = SKAction.repeatForever(anim)
        aura.run(repeatAnim)
        asteroid.addChild(aura)
        asteroid.aura = aura
    }

    func createAsteroid(point: CGPoint, identifier: Int) {
        guard let asteroid = self.copyableAsteroids?[identifier % 4].copy() as! Asteroid? else {
            return
        }

        for child in self.children {
            if child.name == "\(identifier)" {
                print("found identical tag, aborting")
                return
            }
        }

        asteroid.name = "\(identifier)"
        asteroid.position = point

        let rotationDirection = round(random01()) == 0.0 ? -1.0 : 1.0
        let rotationAngle = CGFloat(M_PI * rotationDirection)
        let rotationDuration = random01() * 2.0 + 2.0
        let asteroidRotation = SKAction.repeatForever(SKAction.rotate(byAngle: rotationAngle, duration: rotationDuration))

        let vector = CGVector(dx: CGFloat(frameCanvasWidth*2), dy: 1224)

        let asteroidBeltMovement = SKAction.sequence([SKAction.move(by: vector, duration: random01()*2.0 + 9.0),
                                                      SKAction.removeFromParent()])

        let asteroidBehaviour = SKAction.group([asteroidRotation, asteroidBeltMovement])
        asteroid.run(asteroidBehaviour)

        self.addChild(asteroid)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
