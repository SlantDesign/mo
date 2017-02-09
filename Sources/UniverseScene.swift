//
//  UniverseScene.swift
//  MO
//
//  Created by travis on 2017-02-08.
//  Copyright © 2017 Slant. All rights reserved.
//

import SpriteKit
import MO
import C4

class UniverseScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
    }
}
