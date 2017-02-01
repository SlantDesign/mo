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

    override func didMove(to view: SKView) {
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

            print(orbit.frame)

            orbits.addChild(orbit)

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
