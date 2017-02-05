//
//  CassiniScene.swift
//  MO
//
//  Created by travis on 2017-02-04.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit

class CassiniScene: SKScene {
    let cassini = CassiniSpaceCraft()

    override func didMove(to view: SKView) {
        addChild(cassini)
    }

    func transmit(target: CGPoint) {
        cassini.rotateAndMove(to: target)
    }
}
