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

class PlanetsScene: SKScene {
    var planetsSceneDelegate: PlanetsSceneDelegate?
    var planets = [String: Planet]()
    var orbitsAnchorOffset = CGPoint()
    var orbits = [SKShapeNode]()

    override func didMove(to view: SKView) {
        createCamera()

        guard let delegate = planetsSceneDelegate else {
            return
        }

        self.planets = delegate.planetList()
        guard let orbits = createOrbits() else {
            return
        }

        var dx = CGFloat(SocketManager.sharedManager.deviceID - Planets.primaryDevice)

        if abs(dx) > 2.0 {
            return
        }

        dx *= CGFloat(frameCanvasWidth)

        orbits.position = CGPoint(x: -orbits.frame.midX - dx + orbitsAnchorOffset.x, y:-orbits.frame.midY + orbitsAnchorOffset.y)
        addChild(orbits)
    }

    func createCamera() {
        let cam = SKCameraNode()
        addChild(cam)
        camera = cam
    }

    func zoom(scale: CGFloat) {
        guard camera != nil else {
            print("no camera")
            return
        }

        let zoom = SKAction.scale(to: scale, duration: 1.0)
        zoom.timingMode = .easeOut

        let lineZoom = scale == 5.0 ? lineWidth5() : lineWidth1()
        for orbit in orbits {
            orbit.run(lineZoom, withKey: "lineZoom")
        }

        camera?.run(zoom, withKey: "zoom")
    }

    func lineWidth5() -> SKAction {
        let lineZoom = SKAction.customAction(withDuration: 1.0) { node, elapsedTime in
            guard let shape = node as? SKShapeNode else {
                return
            }

            let progress = elapsedTime / 1.0 * 4.0
            shape.lineWidth = 1.0 + progress
        }
        lineZoom.timingMode = .easeOut

        return lineZoom
    }

    func lineWidth1() -> SKAction {
        let lineZoom = SKAction.customAction(withDuration: 1.0) { node, elapsedTime in
            guard let shape = node as? SKShapeNode else {
                return
            }

            let progress = elapsedTime / 1.0 * 4.0
            shape.lineWidth = 5.0 - progress
        }
        lineZoom.timingMode = .easeOut

        return lineZoom
    }

    func createOrbits() -> SKShapeNode? {
        guard let pluto = planets["pluto"] else {
            return nil
        }

        let orbits = SKShapeNode(rect: CGRect(pluto.path.boundingBox()))
        orbits.lineWidth = 0.0

        for (_, planet) in planets {
            let p = planet.path
            let box = p.boundingBox()
            let center = box.center
            let dxdy = Transform.makeTranslation(Vector(x: -center.x, y: -center.y))
            p.transform(dxdy)

            let orbit = SKShapeNode(path: p.CGPath)
            orbit.fillColor = UIColor.clear
            orbit.strokeColor = UIColor.white
            orbit.lineWidth = 2.0

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
