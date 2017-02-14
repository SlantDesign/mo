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

extension PacketType {
    static let kuiperAsteroid = PacketType(rawValue: 120000)
    static let kuiperComet = PacketType(rawValue: 120001)
    static let explodeKuper = PacketType(rawValue: 120002)
}

public protocol KuiperBeltDelegate {
    func broadcastAddKuiper()
    func broadcastExplodeKuiper()
}

class KuiperBelt: UniverseScene {
    static let primaryDevice = 25
    private var timer: C4.Timer?
    var asteroidCount = 0

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //sets up frames for creating comet aura, as well as copyable asteroids
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        if SocketManager.sharedManager.deviceID == KuiperBelt.primaryDevice {
            timer = C4.Timer(interval: 1.0) {
                self.broadcastAddAsteroid()
            }
            timer?.start()
        }
    }

    //finds an asteroid in the scene's children, based on an identifier
    func findAsteroid(identifier: Int) -> KuiperAsteroid? {
        for child in children {
            if child.name == "\(identifier)" {
                if let asteroid = child as? KuiperAsteroid {
                    return asteroid
                }
            }
        }
        return nil
    }

    func removeAsteroid(identifier: Int) {
        guard let asteroid = findAsteroid(identifier: identifier) else {
            return
        }
        asteroid.removeFromParent()
    }

    //creates an asteroid (with rotation and movement)
    func createAsteroid(point: CGPoint, identifier: Int) {
        guard let asteroid = self.copyableKuiperAsteroids?[identifier % 4].copy() as! KuiperAsteroid? else {
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
        let rotationDuration = 3.0
        let asteroidRotation = SKAction.repeatForever(SKAction.rotate(byAngle: rotationAngle, duration: rotationDuration))

        let vector = CGVector(dx: CGFloat(-frameCanvasWidth*2), dy: 1224)

        let asteroidBeltMovement = SKAction.sequence([SKAction.move(by: vector, duration: 12.0),
                                                      SKAction.removeFromParent()])

        let asteroidBehaviour = SKAction.group([asteroidRotation, asteroidBeltMovement])
        asteroid.run(asteroidBehaviour)

        self.addChild(asteroid)
    }

    //This method is called only on a designated device (see setup where: `SocketManager.sharedManager.deviceID == 18`)
    func broadcastAddAsteroid() {
        var point = CGPoint(x: CGFloat(random01()) * CGFloat(frameCanvasWidth) + CGFloat(frameCanvasWidth/2), y: -size.height/2.0 - 100)
        let data = NSMutableData()
        data.append(&point, length: MemoryLayout<CGPoint>.size)
        asteroidCount += 1
        if asteroidCount == Int.max { asteroidCount = 0 }
        let packet = Packet(type: .kuiperAsteroid, id: asteroidCount, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
    }
}
