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

public protocol SunSpriteDelegate {
    func randomEffect(at point: CGPoint)
}

class SunSprite: SKSpriteNode {
    var sunSpriteDelegate: SunSpriteDelegate?
    var image: Image?

    public convenience init(imageNamed name: String) {
        let t = SKTexture(imageNamed: name)
        self.init(texture: t)
        image = Image(name)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            var p = t.location(in: self)
            p.x += self.frame.width/2.0
            p.y = self.frame.height-p.y
            if !isClear(at: Point(p)) {
                sunSpriteDelegate?.randomEffect(at: convertToSKViewCoordinates(t.location(in: self.scene?.view)))
            }
        }
    }

    func convertToSKViewCoordinates(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - 368.0, y: 512.0 - point.y)
    }

    public func isClear(at point: Point) -> Bool {
        guard let pixelImage = image?.cgimage(at: CGPoint(point)) else {
            print("Could not create pixel Image from CGImage")
            return false
        }

        let imageProvider = pixelImage.dataProvider
        let imageData = imageProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)

        return Double(data[0])/255.0 == 0.0
    }
}

class SunScene: SKScene, SunSpriteDelegate {
    var sun: SunSprite?

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

        let sunSprite = SunSprite(imageNamed: sunAssetFilename)
        sunSprite.isUserInteractionEnabled = true
        sunSprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        sunSprite.position = CGPoint(x: 0.0, y: -view.frame.size.height/2.0)
        sunSprite.sunSpriteDelegate = self
        addChild(sunSprite)

        sun = sunSprite

        createEffectRotations()
        createEffectAnchorPoints()
        createEffects()
    }

    let effectNames = [
        "fire_04",
        "fire_09",
        "fire_10",
        "fire_11",
        "fire_17",
        "sparks_02",
        "sparks_03",
        "sparks_04",
        "sparks_06",
        "sparks_07",
        "sparks_08",
        "sparks_10",
        "sparks_13",
        "sparks_15"
    ]

    var effectAnchorPoints = [String: CGPoint]()
    var effects = [String: [SKTexture]]()

    func createEffectAnchorPoints() {
        effectAnchorPoints["fire_04"] = CGPoint(x:0.0, y:0.5)
        effectAnchorPoints["fire_09"] = CGPoint(x:1.0, y:0.5)
        effectAnchorPoints["fire_10"] = CGPoint(x:0.5, y:0.5)
        effectAnchorPoints["fire_11"] = CGPoint(x:1.0, y:0.0)
        effectAnchorPoints["fire_17"] = CGPoint(x:0.5, y:0.0)
        effectAnchorPoints["sparks_02"] = CGPoint(x:0.5, y:0.0)
        effectAnchorPoints["sparks_03"] = CGPoint(x:0.5, y:0.0)
        effectAnchorPoints["sparks_04"] = CGPoint(x:0.5, y:0.5)
        effectAnchorPoints["sparks_06"] = CGPoint(x:0.5, y:0.0)
        effectAnchorPoints["sparks_07"] = CGPoint(x:1.0, y:0.0)
        effectAnchorPoints["sparks_08"] = CGPoint(x:0.5, y:0.5)
        effectAnchorPoints["sparks_10"] = CGPoint(x:0.0, y:0.0)
        effectAnchorPoints["sparks_13"] = CGPoint(x:0.5, y:0.5)
        effectAnchorPoints["sparks_15"] = CGPoint(x:0.5, y:0.0)
    }

    var effectRotations = [String: CGFloat]()

    func createEffectRotations() {
        effectRotations["fire_04"] = CGFloat(M_PI)
        effectRotations["fire_09"] = CGFloat(-M_PI)
        effectRotations["fire_10"] = CGFloat(2 * M_PI)
        effectRotations["fire_11"] = CGFloat(-M_PI_2)
        effectRotations["fire_17"] = CGFloat(0)
        effectRotations["sparks_02"] = CGFloat(0)
        effectRotations["sparks_03"] = CGFloat(0)
        effectRotations["sparks_04"] = CGFloat(2 * M_PI)
        effectRotations["sparks_06"] = CGFloat(2 * M_PI)
        effectRotations["sparks_07"] = CGFloat(-M_PI_2)
        effectRotations["sparks_08"] = CGFloat(2 * M_PI)
        effectRotations["sparks_10"] = CGFloat(M_PI_4 * 3.0)
        effectRotations["sparks_13"] = CGFloat(2 * M_PI)
        effectRotations["sparks_15"] = CGFloat(0)
    }

    func createEffects() {
        for effectName in effectNames {
            var currentEffectFrames = [SKTexture]()
            let currentAtlas = SKTextureAtlas(named: effectName)
            let names = currentAtlas.textureNames.sorted()
            for i in 0..<currentAtlas.textureNames.count {
                let name = names[i]
                if !name.contains("@") {
                    currentEffectFrames.append(SKTexture(imageNamed: name))
                }
            }
            effects[effectName] = currentEffectFrames
        }
    }

    func randomEffect(at point: CGPoint) {
        let index = random(below: effectNames.count)
        let effectName = effectNames[index]
        if let frames = effects[effectName] {
            let currentEffect = SKSpriteNode(texture: frames[0])
            if let anchorPoint = effectAnchorPoints[effectName] {
                currentEffect.anchorPoint = anchorPoint
            }
            currentEffect.position = point
            let rotate = SKAction.rotate(byAngle: CGFloat(random01()) * effectRotations[effectName]!, duration: 0.0)
            let animate = SKAction.animate(with: frames, timePerFrame: 0.08333, resize: false, restore: true)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([rotate, animate, remove])
            addChild(currentEffect)
            currentEffect.run(sequence)
        }
    }
}
