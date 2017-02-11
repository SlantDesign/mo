//
//  Sun.swift
//  MO
//
//  Created by travis on 2017-02-08.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import C4
import MO

extension PacketType {
    static let sun = PacketType(rawValue: 700000)
}

class Sun: UniverseScene, SunSpriteDelegate {
    static let primaryDevice = 18
    var sun: SunSprite?
    var flareSounds: [SKAudioNode]?

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        scaleMode = .aspectFill
        size = view.bounds.size

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
        sunSprite.position = CGPoint(x: 0, y: -view.frame.size.height/2.0)
        sunSprite.sunSpriteDelegate = self
        addChild(sunSprite)

        sun = sunSprite

        createEffectRotations()
        createEffectAnchorPoints()
        createAudio()
        createAtlases()
    }

    func preload() {

    }

    func createAudio() {
        flareSounds = [SKAudioNode]()
        for i in 0...4 {
            let flare = SKAudioNode(fileNamed: "flare\(i).aiff")
            flare.autoplayLooped = false
            flareSounds?.append(flare)
        }

        let sunAmbient = SKAudioNode(fileNamed: "sunAmbient.mp3")
        sunAmbient.autoplayLooped = true
        addChild(sunAmbient)
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
    var atlases = [String: SKTextureAtlas]()

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

            guard let currentAtlas = atlases[effectName] else {
                print("Couldn't access atlas")
                return
            }
            let names = currentAtlas.textureNames.sorted()
            for i in 0..<currentAtlas.textureNames.count {
                let name = names[i]
                if !name.contains("@") {
                    let texture = SKTexture(imageNamed: name)
                    currentEffectFrames.append(texture)
                }
            }
            effects[effectName] = currentEffectFrames
        }
    }

    func createAtlases() {
        for effectName in effectNames {
            let currentAtlas = SKTextureAtlas(named: effectName)
            currentAtlas.preload {
                self.atlases[effectName] = currentAtlas
                if self.atlases.count == self.effectNames.count {
                    self.createEffects()
                }
            }
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
            if let anchorPoint = self.effectAnchorPoints[effectName] {
                currentEffect.anchorPoint = anchorPoint
            }
            currentEffect.position = point
            let rotate = SKAction.rotate(byAngle: angle, duration: 0.0)
            let animate = SKAction.animate(with: frames, timePerFrame: 0.08333, resize: false, restore: true)
            let remove = SKAction.removeFromParent()

            let sequence = SKAction.sequence([rotate, animate, remove])
            self.addChild(currentEffect)

            let randomFlare = SKAudioNode(fileNamed: "flare\(random(below: 5)).aiff")
            randomFlare.autoplayLooped = false
            currentEffect.addChild(randomFlare)
            let audio = SKAction.run({
                randomFlare.run(SKAction.play())
            })
            let group = SKAction.group([sequence, audio])
            currentEffect.run(group)
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
