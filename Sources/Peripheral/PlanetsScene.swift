//
//  PlanetsScene.swift
//  MO
//
//  Created by travis on 2017-01-31.
//  Copyright © 2017 Slant. All rights reserved.
//

//
//  GameScene.swift
//  PlanetsTest
//
//  Created by travis on 2017-01-31.
//  Copyright © 2017 C4. All rights reserved.
//

import SpriteKit
import C4

public enum PlanetZoom: Int {
    case large
    case medium
    case small
}

class PlanetsScene: SKScene {
    var planetsSceneDelegate: PlanetsSceneDelegate?
    var planets = [String: Planet]()

    override func didMove(to view: SKView) {
        guard let delegate = planetsSceneDelegate else {
            print("planetsSceneDelegate not initialized")
            return
        }

        self.planets = delegate.planetList()

//        let r: CGFloat = 3660.0//max
        let r: CGFloat = 360.0

        for (name, planet) in self.planets {
            if name == "sun" {
                continue
            }
            let planetSprite = SKSpriteNode(imageNamed: name)
            planetSprite.setScale(0.05)
            let dx = CGFloat(Planets.primaryDevice - SocketManager.sharedManager.deviceID) * CGFloat(frameCanvasWidth)
            let radius = r * planet.radius
            planetSprite.position = CGPoint(x: radius * cos(planet.angle) + dx, y: radius * sin(planet.angle))
            addChild(planetSprite)
        }
    }
}

class PathPlanetsScene: SKScene {
    var planetsSceneDelegate: PlanetsSceneDelegate?
    var planets = [String: Planet]()
    var orbitsAnchorOffset = CGPoint()
    var orbitsCenters = [String: CGPoint]()
    var framesLarge = [String: CGRect]()
    var framesMedium = [String: CGRect]()
    var framesSmall = [String: CGRect]()
    var orbits = [SKShapeNode]()
    var allOrbits: SKShapeNode?
    var allOrbitsCenter = CGPoint()

    override func didMove(to view: SKView) {
        createCamera()

        guard let delegate = planetsSceneDelegate else {
            return
        }

        self.planets = delegate.planetList()

        guard let orbits = createOrbits() else {
            return
        }
        allOrbits = orbits

        generateTargetFrames()

        var dx = CGFloat(SocketManager.sharedManager.deviceID - Planets.primaryDevice)

        if abs(dx) > 2.0 {
            return
        }

        dx *= CGFloat(frameCanvasWidth)

        orbits.position = CGPoint(x: -orbits.frame.midX - dx + orbitsAnchorOffset.x, y:-orbits.frame.midY + orbitsAnchorOffset.y)
        allOrbitsCenter = orbits.position
        addChild(orbits)
    }

    func generateTargetFrames() {
        for orbit in orbits {
            guard let name = orbit.name else {
                print("error retrieving name of orbit")
                return
            }

            let position = orbit.position
            orbitsCenters[name] = position

            let mediumFrame = orbit.frame
            framesMedium[name] = mediumFrame

            let largeFrame = orbit.frame.insetBy(dx: -orbit.frame.width * 2.0, dy: -orbit.frame.height * 2.0)
            framesLarge[name] = largeFrame

            let smallFrame = orbit.frame.insetBy(dx: orbit.frame.width * 0.4, dy: orbit.frame.height * 0.4)
            framesSmall[name] = smallFrame
        }
    }

    func createCamera() {
        let cam = SKCameraNode()
        addChild(cam)
        camera = cam
    }

    func zoom(level: PlanetZoom) {
        switch level {
        case PlanetZoom.large:
            zoom(scale: 2.0)
        case PlanetZoom.small:
            zoom(scale: 0.5)
        default:
            zoom(scale: 1.0)
        }
    }

    func zoom(scale: CGFloat) {
//        for orbit in orbits {
//            let x = SKAction.scaleX(to: scale, duration: 1.0)
//            let y = SKAction.scaleY(to: scale, duration: 1.0)
//            let group = SKAction.group([x, y, move])
//            group.timingMode = .easeOut
//            orbit.run(group)
//        }

//        let x = SKAction.scaleX(to: scale, duration: 1.0)
//        let y = SKAction.scaleY(to: scale, duration: 1.0)
//        let move = SKAction.move(to: CGPoint(), duration: 1.0)
//        let group = SKAction.group([x, y, move])
//        group.timingMode = .easeOut
//        allOrbits?.run(group)


    }

    func zoom(frames: [String: CGRect]) {
        for orbit in orbits {
            guard let name = orbit.name else {
                print("Could not extract name from orbit")
                return
            }

            if let frame = frames[name], let position = orbitsCenters[name] {
//                let resize = SKAction.resize(byWidth: frame.width, height: frame.height, duration: 1.0)
                let scale = frame.width / orbit.frame.width
                if scale == 0.2 {
                    orbit.lineWidth = 5.0
                }
                print(scale)
                print(orbit.frame)
                orbit.setScale(scale)
                print(orbit.frame)
                let reposition = SKAction.move(to: position, duration: 1.0)
//                let animationGroup = SKAction.group([reposition])
                orbit.run(reposition)
            }
        }
    }

//    func zoom(scale: CGFloat) {
//        guard camera != nil else {
//            print("no camera")
//            return
//        }
//
//        let currentWidth = orbits[0].lineWidth
//
//        let zoom = SKAction.scale(to: scale, duration: 1.0)
//        zoom.timingMode = .easeOut
//
//        let lineZoom = lineWidthAction(from: currentWidth, to: scale)
//
//        for orbit in orbits {
//            orbit.run(lineZoom, withKey: "lineZoom")
//        }
//
//        camera?.run(zoom, withKey: "zoom")
//    }
//
//    func lineWidth5() -> SKAction {
//        let lineZoom = SKAction.customAction(withDuration: 1.0) { node, elapsedTime in
//            guard let shape = node as? SKShapeNode else {
//                return
//            }
//
//            let progress = elapsedTime / 1.0 * 4.0
//            shape.lineWidth = 1.0 + progress
//        }
//        lineZoom.timingMode = .easeOut
//
//        return lineZoom
//    }
//
//    func lineWidth1() -> SKAction {
//        let lineZoom = SKAction.customAction(withDuration: 1.0) { node, elapsedTime in
//            guard let shape = node as? SKShapeNode else {
//                return
//            }
//
//            let progress = elapsedTime / 1.0 * 4.0
//            shape.lineWidth = 5.0 - progress
//        }
//        lineZoom.timingMode = .easeOut
//
//        return lineZoom
//    }

    func createOrbits() -> SKShapeNode? {
        guard let pluto = planets["neptune"] else {
            return nil
        }

        let orbits = SKShapeNode(rect: CGRect(pluto.path.boundingBox()))
        orbits.lineWidth = 0.0

        for (name, planet) in planets {
            let p = planet.path
            let box = p.boundingBox()
            let center = box.center
            let dxdy = Transform.makeTranslation(Vector(x: -center.x, y: -center.y))
            p.transform(dxdy)

            let orbit = SKShapeNode(path: p.CGPath)
            orbit.fillColor = UIColor.clear
            orbit.strokeColor = UIColor.white
            orbit.lineWidth = 1.0
            orbit.name = name

            orbits.addChild(orbit)
            self.orbits.append(orbit)

            if planet.name == "sun" {
                let frame = CGRect(planet.path.boundingBox())
                let anchor = CGPoint(x: frame.midX, y: frame.midY)
                orbitsAnchorOffset.x = orbits.frame.midX - frame.midX
                orbitsAnchorOffset.y = orbits.frame.midY - frame.midY
            }
        }
        return orbits
    }
}
