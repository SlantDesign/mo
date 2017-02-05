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
    var rocket: Rocket?
    var launching = false
    var launchTime: TimeInterval = 0.0
    var preiginte: SKEmitterNode?
    var ignition: SKEmitterNode?
    var rocketFire: SKEmitterNode?
    var audio: AudioPlayer?

    override func didMove(to view: SKView) {
        loadRocket(in: view)
    }

    func loadRocket(in view: SKView) {
        switch SocketManager.sharedManager.deviceID - Rockets.primaryDevice {
        case 1:
            loadSoyuz(in: view)
        case 2:
            loadAriane(in: view)
        case 3:
            loadFalcon(in: view)
        default:
            loadEndeavour(in: view)
        }
    }

    func loadEndeavour(in view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 80.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)

        rocket = Endeavour()
        rocket?.position = CGPoint(x: 0, y: 180.0-view.frame.height/2.0)
        if let r = rocket {
            addChild(r)
        }
    }

    func loadSoyuz(in view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 80.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)

        rocket = Soyuz()
        rocket?.position = CGPoint(x: 0, y: 180.0-view.frame.height/2.0)
        if let r = rocket {
            addChild(r)
        }
    }

    func loadAriane(in view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 80.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)

        rocket = Ariane()
        rocket?.position = CGPoint(x: 0, y: 180.0-view.frame.height/2.0)
        if let r = rocket {
            addChild(r)
        }
    }

    func loadFalcon(in view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 80.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)

        rocket = Falcon()
        rocket?.position = CGPoint(x: 0, y: 180.0-view.frame.height/2.0)
        if let r = rocket {
            addChild(r)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let r = rocket else {
            print("Couldn't extract rocket")
            return
        }

        if !r.launching {
            r.launch()
        }
    }
}
