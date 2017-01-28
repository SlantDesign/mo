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
import MO

class Asteroid: SKSpriteNode {
    public var aura: SKSpriteNode?
    public var rotationAngle: CGFloat = 0.0
    public var rotationDuration: TimeInterval = 0.0
    public var imageID = 0

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let aura = aura {
//            aura.isHidden = !aura.isHidden
//        }

        let deviceId = SocketManager.sharedManager.deviceID

        var d = Data()
        d.append(imageID)
        d.append(position)
        let packet = Packet(type: .comet, id: deviceId, payload: d)
        SocketManager.sharedManager.broadcastPacket(packet)

        /*
        isHidden = true
        self.removeFromParent()
 */
    }
}

class CometScene: SKScene {
    var cometDelegate: CometSceneDelegate?
    var cometAuraFrames: [SKTexture]?
    var cometAura: SKSpriteNode?
    let cometAuraAtlas = SKTextureAtlas(named: "comet_aura")

    override func didMove(to view: SKView) {
        cometAuraFrames = [SKTexture]()
        for i in 0..<cometAuraAtlas.textureNames.count/2 {
            let texture = cometAuraAtlas.textureNamed("comet_aura_\(i)")
            cometAuraFrames?.append(texture)
        }

        if SocketManager.sharedManager.deviceID == 17 {
            createComets()
        }
    }

    func createComets() {
        createComet(imageID: 0, at: CGPoint(x: 0, y: -300))
        createComet(imageID: 1, at: CGPoint(x: 0, y: -150))
        createComet(imageID: 2, at: CGPoint(x: 0, y: 150))
        createComet(imageID: 3, at: CGPoint(x: 0, y: 300))
    }

    func createMovingComet(imageID: Int, at point: CGPoint) {
        let asteroid = createAsteroid(imageID: imageID, at: point)
        addAura(to: asteroid)
        asteroid.aura?.isHidden = false
        self.addChild(asteroid)
        cometAura = asteroid

        let movement = SKAction.move(by: CGVector(dx: CGFloat(frameCanvasWidth * 4.0), dy: 0.0), duration: 5.0)
        let scale = SKAction.scale(by: 0.25, duration: 1.5)
        let fade = SKAction.fadeOut(withDuration: 1.5)
        let wait = SKAction.wait(forDuration: movement.duration-1.5)
        let fadeScale = SKAction.group([fade, scale])
        let waitFadeScale = SKAction.sequence([wait, fadeScale, SKAction.removeFromParent()])
        let moveComet = SKAction.group([movement, waitFadeScale])

        asteroid.run(moveComet)
    }

    func addAsteroid(imageID: Int, to aura: SKSpriteNode) {
        let asteroid = Asteroid(imageNamed: "Asteroid_0\(imageID)")
        asteroid.imageID = imageID
        asteroid.size = CGSize(width: 132, height: 132)
        asteroid.position = CGPoint(x: aura.frame.width/2-asteroid.size.width/2 - 20.0, y: 0)

        let direction: CGFloat = random(below: 2) == 0 ? -1.0 : 1.0
        let angle = CGFloat(2.0 * M_PI) * direction
        asteroid.rotationAngle = angle
        asteroid.rotationDuration = 2.0 * random01() + 1.0
        let rotation = SKAction.rotate(byAngle: asteroid.rotationAngle, duration: asteroid.rotationDuration)
        let repeatRotation = SKAction.repeatForever(rotation)
        asteroid.run(repeatRotation)
        aura.addChild(asteroid)
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

        let anim = SKAction.animate(with: frames, timePerFrame: 0.08333, resize: false, restore: true)
        let repeatAnim = SKAction.repeatForever(anim)
        let rotation = SKAction.rotate(byAngle: -asteroid.rotationAngle, duration: asteroid.rotationDuration)
        let repeatRotation = SKAction.repeatForever(rotation)
        let group = SKAction.group([repeatAnim, repeatRotation])
        aura.run(group, withKey: "cometAura")
        aura.isHidden = true
        asteroid.addChild(aura)
        asteroid.aura = aura
    }

    func createAsteroid(imageID: Int, at point: CGPoint) -> Asteroid {
        let asteroid = Asteroid(imageNamed: "Asteroid_0\(imageID)")
        asteroid.imageID = imageID
        asteroid.size = CGSize(width: 90, height: 90)
        asteroid.position = point

        let direction: CGFloat = random(below: 2) == 0 ? -1.0 : 1.0
        let angle = CGFloat(2.0 * M_PI) * direction
        asteroid.rotationAngle = angle
        asteroid.rotationDuration = 2.0 * random01() + 1.0
        let rotation = SKAction.rotate(byAngle: asteroid.rotationAngle, duration: asteroid.rotationDuration)
        let repeatRotation = SKAction.repeatForever(rotation)
        asteroid.run(repeatRotation)
        return asteroid
    }

    func createComet(imageID: Int, at point: CGPoint) {
        let asteroid = createAsteroid(imageID: imageID, at: point)
        addAura(to: asteroid)
        self.addChild(asteroid)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

    func animate(aura: SKSpriteNode) {
        guard let frames = cometAuraFrames else {
            print("Frames weren't available")
            return
        }

        let anim = SKAction.animate(with: frames, timePerFrame: 0.08333, resize: false, restore: true)
        let repeatAnim = SKAction.repeatForever(anim)
        let angle = CGFloat(-2.0 * M_PI)
        let rotation = SKAction.rotate(byAngle: angle, duration: 2.0)
        let repeatRotation = SKAction.repeatForever(rotation)
        let group = SKAction.group([repeatAnim, repeatRotation])
        aura.run(group, withKey: "cometAura")
    }
}
