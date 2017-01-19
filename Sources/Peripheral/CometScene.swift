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

class CometScene: SKScene {
    private var nodes: [SKSpriteNode]?// = [SKSpriteNode]()
    var cometDelegate: CometSceneDelegate?

    override func didMove(to view: SKView) {
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cometDelegate?.fire()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
