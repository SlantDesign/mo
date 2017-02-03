//
//  SolarSystemScene.swift
//  MO
//
//  Created by travis on 2017-02-03.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import MO
import CocoaAsyncSocket
import C4

extension PacketType {
    static let planet = PacketType(rawValue: 800000)
}

class SolarSystemScene: SKScene {
    var planets = [String: PlanetNode]()

    func createPlanets() {
        planets["mercury"] = PlanetNode(imageNamed: "Mercury")
        planets["venus"] = PlanetNode(imageNamed: "Venus")
        planets["earth"] = PlanetNode(imageNamed: "Earth")
        planets["mars"] = PlanetNode(imageNamed: "Mars")
        planets["jupiter"] = PlanetNode(imageNamed: "Jupiter")
        planets["saturn"] = PlanetNode(imageNamed: "Saturn")
        planets["uranus"] = PlanetNode(imageNamed: "Uranus")
        planets["neptune"] = PlanetNode(imageNamed: "Neptune")



        var locations = [CGPoint(x: -125, y: -300),
                         CGPoint(x: -125, y: -100),
                         CGPoint(x: -125, y: 100),
                         CGPoint(x: -125, y: 300),
                         CGPoint(x: 125, y: -100),
                         CGPoint(x: 125, y: -300),
                         CGPoint(x: 125, y: 100),
                         CGPoint(x: 125, y: 300)]

        planets["mercury"]?.position = locations[0]
        planets["venus"]?.position = locations[1]
        planets["earth"]?.position = locations[2]
        planets["mars"]?.position = locations[3]
        planets["jupiter"]?.position = locations[4]
        planets["saturn"]?.position = locations[5]
        planets["uranus"]?.position = locations[6]
        planets["neptune"]?.position = locations[7]

        for (name, planet) in planets {
            planet.name = name
            planet.xScale = 0.25
            planet.yScale = 0.25
            planet.isUserInteractionEnabled = true
            planet.physicsBody = SKPhysicsBody(circleOfRadius: planet.frame.height/2.0)
            planet.physicsBody?.isDynamic = true
            planet.physicsBody?.affectedByGravity = false
            addChild(planet)
        }
    }

    override func didMove(to view: SKView) {
        var bounds = view.bounds
        bounds.origin = CGPoint(x: -bounds.width/2.0, y: -bounds.height/2.0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: bounds)
        self.physicsBody?.isDynamic = true
        createPlanets()
    }

    public func apply(impulse: CGVector, to name: String) {
        guard let planet = planets[name] else {
            print("Couldn't find planet named: \(name)")
            return
        }
        planet.physicsBody?.applyImpulse(impulse)
    }
}

class PlanetNode: SKSpriteNode {
    public convenience init(imageNamed name: String) {
        let t = SKTexture(imageNamed: name)
        self.init(texture: t, color: UIColor.clear, size: t.size())
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func randomDirection() -> CGFloat {
        return random(below: 2) == 0 ? -1.0 : 1.0
    }

    func randomVector() -> CGVector {
        let x = CGFloat(random01()) * 200.0 + 200.0
        let y = CGFloat(random01()) * 200.0 + 200.0
        return CGVector(dx: x * randomDirection(), dy: y * randomDirection())
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let n = name else {
            print("Couldn't get name of planet")
            return
        }

        let data = NSMutableData()
        var index = SolarSystem.planetNames.index(of: n)
        data.append(&index, length: MemoryLayout<Int>.size)
        var v = randomVector()
        data.append(&v, length: MemoryLayout<CGVector>.size)

        let packet = Packet(type: .planet, id: SocketManager.sharedManager.deviceID, payload: data as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
    }
}
