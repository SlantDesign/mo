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

extension PacketType {
    static let rockets = PacketType(rawValue: 900000)
}

class Rockets: UniverseScene {
    static let endeavourDevice = 7
    static let soyuzDevice = 13
    static let arianeDevice = 22
    static let falconDevice = 28
    var rocket: Rocket?
    var launching = false
    var launchTime: TimeInterval = 0.0
    var preiginte: SKEmitterNode?
    var ignition: SKEmitterNode?
    var rocketFire: SKEmitterNode?
    var audio: AudioPlayer?

    override func didMove(to view: SKView) {
        loadRocket()
    }

    func loadRocket() {
        switch SocketManager.sharedManager.deviceID {
        case Rockets.soyuzDevice:
            rocket = Soyuz()
        case Rockets.arianeDevice:
            rocket = Ariane()
        case Rockets.falconDevice:
            rocket = Falcon()
        default:
            rocket = Endeavour()
        }

        guard let r = rocket else {
            print("Could not load rocket \(SocketManager.sharedManager.deviceID).")
            return
        }
        addChild(r)
    }

    func createGround(in view: SKView) {
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 10.0))
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.position = CGPoint(x: -view.frame.width/2.0, y: 80.0-view.frame.height/2.0)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = true
        addChild(ground)
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
