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
    var data: UnsafePointer<UInt8>?
    var imageData: CFData?
    var imageScale: CGFloat = 1.0

    public convenience init(imageNamed name: String) {
        let t = SKTexture(imageNamed: name)
        self.init(texture: t)
        image = Image(name)

        guard let cgimg: CGImage = image?.cgImage else {
            print("Could not create cgimage")
            return
        }

        guard let scale = image?.uiimage.scale else {
            print("Could not get scale")
            return
        }
        imageScale = scale

        guard let imageProvider = cgimg.dataProvider else {
            print("Could not create imageProvider")
            return
        }

        let imageData = imageProvider.data
        data = CFDataGetBytePtr(imageData)
        let length = CFDataGetLength(imageData)
        self.imageData = imageData
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
            if !isTransparent(at: Point(p)) {
                sunSpriteDelegate?.randomEffect(at: convertToSKViewCoordinates(t.location(in: self.scene?.view)))
            }
        }
    }

    func convertToSKViewCoordinates(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - 368.0, y: 512.0 - point.y)
    }

    public func isTransparent(at point: Point) -> Bool {
        let position = 4*(Int(self.frame.width * 2.0) * Int(point.y * 2.0) + Int(point.x * 2.0))
        guard let value = data?[position+3] else {
            print("Could not get value from data")
            return false
        }
        return Double(value)/255.0 == 0.0
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

    func createEffect(nameIndex: Int, at point: CGPoint, angle intAngle: Int) {
        let name = effectNames[nameIndex]
        guard let rotation = effectRotations[name] else {
            print("Could not extract rotation")
            return
        }
        let angle = CGFloat(intAngle)/1000.0 * rotation
        createEffect(named: name, at: point, angle: angle)
    }

    func createEffect(named effectName: String, at point: CGPoint, angle: CGFloat) {
        if let frames = effects[effectName] {
            let currentEffect = SKSpriteNode(texture: frames[0])
            currentEffect.isUserInteractionEnabled = false
            if let anchorPoint = effectAnchorPoints[effectName] {
                currentEffect.anchorPoint = anchorPoint
            }
            currentEffect.position = point
            let rotate = SKAction.rotate(byAngle: angle, duration: 0.0)
            let animate = SKAction.animate(with: frames, timePerFrame: 0.08333, resize: false, restore: true)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([rotate, animate, remove])
            addChild(currentEffect)
            currentEffect.run(sequence)
        }
    }

    func randomEffect(at point: CGPoint) {
        let index = random(below: effectNames.count)
        let angle = random(below: 1000)

        if abs(point.x) > 300.0 {
            var id = SocketManager.sharedManager.deviceID
            if point.x < 0 {
                id -= 1
            } else {
                id += 1
            }
            var data = Data()
            data.append(id)
            data.append(point)
            data.append(index)
            data.append(angle)

            let packet = Packet(type: .sun, id: SocketManager.sharedManager.deviceID, payload: data)
            SocketManager.sharedManager.broadcastPacket(packet)
        } else {
            createEffect(nameIndex: index, at: point, angle: angle)
        }
    }
}
