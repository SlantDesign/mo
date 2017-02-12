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
    static let planetVelocity = PacketType(rawValue: 800001)
    static let planetPosition = PacketType(rawValue: 800002)
    static let planetIsDynamic = PacketType(rawValue: 800003)
}

class SolarSystem: UniverseScene, SKPhysicsContactDelegate {
    static let primaryDevice = 17
    static let planetNames: [String] = ["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]
    static let contactBitmask: UInt32 = 0x2
    var planets = [String: Planet]()
    var planetFields = [String: SKFieldNode]()
    var planetFieldBitmasks = [String: UInt32]()
    var planetBounces = [AudioPlayer("planetBounce0.aiff"), AudioPlayer("planetBounce1.aiff"), AudioPlayer("planetBounce2.aiff")]

    func createPlanets() {
        planets["mercury"] = Planet(imageNamed: "Mercury")
        planets["venus"] = Planet(imageNamed: "Venus")
        planets["earth"] = Planet(imageNamed: "Earth")
        planets["mars"] = Planet(imageNamed: "Mars")
        planets["jupiter"] = Planet(imageNamed: "Jupiter")
        planets["saturn"] = Planet(imageNamed: "Saturn")
        planets["uranus"] = Planet(imageNamed: "Uranus")
        planets["neptune"] = Planet(imageNamed: "Neptune")

        var locations = [CGPoint]()
        let offset = CGFloat(SolarSystem.primaryDevice - SocketManager.sharedManager.deviceID) * CGFloat(frameCanvasWidth)
        for i in 0..<planets.count {
            locations.append(CGPoint(x: offset - CGFloat(frameCanvasWidth/4.0) + CGFloat(frameCanvasWidth/2.0) * CGFloat(i), y: 0.0))
        }

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
            planet.physicsBody?.contactTestBitMask = SolarSystem.contactBitmask
            addChild(planet)
        }
    }

    func createFields() {
        for i in 0..<SolarSystem.planetNames.count {
            let name = SolarSystem.planetNames[i]
            planetFieldBitmasks[name] = 0x1 << UInt32(i)
        }

        for (name, planet) in planets {
            let gravity = SKFieldNode.springField()
            guard let bitmask = planetFieldBitmasks[name] else {
                print("Couldn't create bitmask for \(name)")
                continue
            }
            gravity.position = planet.position
            gravity.categoryBitMask = bitmask
            gravity.physicsBody?.isDynamic = true
            planet.physicsBody?.fieldBitMask = bitmask
            planet.physicsBody?.linearDamping = 2.0
            addChild(gravity)
        }
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        createPlanets()
        createFields()
    }

    public func apply(impulse: CGVector, to name: String) {
        guard let planet = planets[name] else {
            print("Couldn't find planet named: \(name)")
            return
        }
        planet.physicsBody?.applyImpulse(impulse)
    }

    func set(isDynamic: Bool, for name: String) {
        guard let planet = planets[name] else {
            print("Couldn't find a planet named: \(name)")
            return
        }
        planet.physicsBody?.isDynamic = isDynamic
    }

    func set(velocity: CGVector, for name: String) {
        guard let planet = planets[name] else {
            print("Couldn't find a planet named: \(name)")
            return
        }
        planet.physicsBody?.isDynamic = true
        planet.physicsBody?.velocity = velocity
    }

    func set(position: CGPoint, for name: String) {
        guard let planet = planets[name] else {
            print("Couldn't find a planet named: \(name)")
            return
        }
        planet.position = position
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var aIsPlanet = false
        var bIsPlanet = false
        var aIsAsteroid = false
        var bIsAsteroid = false

        if let a = contact.bodyA.node as? Planet {
            aIsPlanet = true
        } else if let a = contact.bodyA.node as? Asteroid {
            aIsAsteroid = true
        }

        if let b = contact.bodyB.node as? Planet {
            bIsPlanet = true
        } else if let b = contact.bodyB.node as? Asteroid {
            bIsAsteroid = true
        }

        if aIsPlanet && bIsPlanet {
            for sound in planetBounces {
                if sound?.playing == false {
                    sound?.play()
                    return
                }
            }
        } else if aIsAsteroid && bIsPlanet || aIsPlanet && bIsAsteroid {
            print("should explode asteroid")
        }
    }
}
