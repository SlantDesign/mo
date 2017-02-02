//
//  SunScene.swift
//  MO
//
//  Created by travis on 2017-02-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import SpriteKit
import MO
import C4

class SunScene: SKScene {
    override func didMove(to view: SKView) {
        var sunAssetFilename = ""
        switch SocketManager.sharedManager.deviceID {
        case Sun.primaryDevice-1:
            sunAssetFilename = "SunLeft"
        case Sun.primaryDevice+1:
            sunAssetFilename = "SunRight"
        default:
            sunAssetFilename = "SunMiddle"
        }


        let sunSprite = SKSpriteNode(imageNamed: sunAssetFilename)
        sunSprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        sunSprite.position = CGPoint(x: 0.0, y: -view.frame.size.height/2.0)
        addChild(sunSprite)
    }
}
