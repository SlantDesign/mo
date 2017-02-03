//
//  HelloMO.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import SpriteKit

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let planets = PacketType(rawValue: 600000)
    static let planetsLarge = PacketType(rawValue: 600001)
    static let planetsMedium = PacketType(rawValue: 600002)
    static let planetsSmall = PacketType(rawValue: 600003)
}

public protocol PlanetsSceneDelegate {
    func planetList() -> [String: Planet]
}

class Planets: UniverseController, GCDAsyncSocketDelegate, PlanetsSceneDelegate {
    let socketManager = SocketManager.sharedManager

    static let primaryDevice = 18
    let planetsView = SKView()
    var planetsScene: PlanetsScene?
    var asteroidCount = 0
    var planets = [String: Planet]()

    private var timer: C4.Timer?

    var isZoomed = false

    //creates the asteroidBelt view and sets up a timer from the primary device
    override func setup() {

        createPlanets()
        planetsView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)

        guard let scene = PlanetsScene(fileNamed: "PlanetsScene") else {
            print("Could not load PlanetsScene")
            return
        }

        scene.planetsSceneDelegate = self
        scene.scaleMode = .aspectFill
        canvas.add(planetsView)
        planetsView.presentScene(scene)
        planetsScene = scene

        planetsView.ignoresSiblingOrder = false
        planetsView.showsFPS = true
        planetsView.showsNodeCount = true

        canvas.addTapGestureRecognizer { (points, point, state) in
            self.toggleZoom()
        }
    }

    func toggleZoom() {
        if isZoomed {
//            planetsScene?.zoom(level: PlanetZoom.large)
        } else {
//            planetsScene?.zoom(level: PlanetZoom.small)
        }
        isZoomed = !isZoomed
    }

    func planetList() -> [String : Planet] {
        return planets
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.planetsLarge:
            break
//            planetsScene?.zoom(level: PlanetZoom.large)
        case PacketType.planetsSmall:
            break
//            planetsScene?.zoom(level: PlanetZoom.small)
        case PacketType.planetsMedium:
            fallthrough
        default:
//            planetsScene?.zoom(level: PlanetZoom.medium)
            break
        }
    }

    //This is how you send a packet, with no data
    func send(type: PacketType) {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: type, id: deviceId)
        socketManager.broadcastPacket(packet)
    }

    func planetOrbitView() -> View? {
        guard let pluto = planets["pluto"] else {
            return nil
        }

        let v = View(frame: pluto.path.boundingBox())

        for (_, planet) in planets {
            let orbit = Shape(planet.path)
            orbit.fillColor = clear
            orbit.strokeColor = C4Blue
            orbit.lineWidth = 2.0

            v.add(orbit)

            if planet.name == "sun" {
                let frame = planet.path.boundingBox()
                var center = frame.center
                center.x /= v.width
                center.y /= v.height
                v.anchorPoint = center
            }
        }

        return v
    }

    func createPlanets() {
//        let flatOrbits = [Rect(1197.53, 1759.78, 29.32, 30.3),
//                                Rect(1185.11, 1743.7, 56.1, 56.44),
//                                Rect(1174.05, 1733.38, 78, 78),
//                                Rect(1148.61, 1710.34, 118.34, 118.34),
//                                Rect(1001.01, 1571.62, 404.64, 404.64),
//                                Rect(829.36, 1427.7, 747.46, 749.28),
//                                Rect(489.11, 1038.58, 1500.36, 1498.56),
//                                Rect(21.78, 611.06, 2347.36, 2349.18),
//                                Rect(0, 0, 2929.84, 3028.66),
//                                Rect(1211.19, 1770.1, 3.36, 3.36)]
        let flatOrbits = [
            Rect(2036.74, 2993.01, 49.87, 51.53),
            Rect(2015.62, 2965.66, 95.41, 95.99),
            Rect(1996.81, 2948.11, 132.66, 132.66),
            Rect(1953.54, 2908.92, 201.27, 201.27),
            Rect(1702.5, 2672.99, 688.21, 688.21),
            Rect(1410.56, 2428.21, 1271.27, 1274.36),
            Rect(831.87, 1766.4, 2551.79, 2548.73),
            Rect(37.04, 1039.28, 3992.35, 3995.45),
            Rect(0, 0, 4983.03, 5151.1),
            Rect(2059.97, 3010.56, 5.71, 5.71)]

        createPlanets(withRects: flatOrbits)

    }
    /*
     4.32743159409059
     1.84149638543053
     2.46163354241031
     0.494565588563849
     3.47907712384
     4.55384312140337
     0.322185904826256
     5.88282247543638

     */
    func createPlanets(withRects rects: [Rect]) {
        var mercury = Planet()
        mercury.path.addEllipse(rects[0])
        mercury.name = "mercury"
        mercury.rotation = 58.8
        mercury.orbit = 0.241
        mercury.scale = 0.383
        mercury.radius = 0.0129
        mercury.angle = 4.3274
        planets[mercury.name] = mercury

        var venus = Planet()
        venus.path.addEllipse(rects[1])
        venus.name = "venus"
        venus.rotation = -244.0
        venus.orbit = 0.615
        venus.scale = 0.949
        venus.radius = 0.0240
        venus.angle = 1.8415
        planets[venus.name] = venus

        var earth = Planet()
        earth.radius = 0.0332
        earth.angle = 2.4616
        planets[earth.name] = earth

        var mars = Planet()
        mars.path.addEllipse(rects[3])
        mars.name = "mars"
        mars.rotation = 1.03
        mars.orbit = 1.88
        mars.scale = 0.532
        mars.radius = 0.0506
        mars.angle = 0.4946
        planets[mars.name] = mars

        var jupiter = Planet()
        jupiter.path.addEllipse(rects[4])
        jupiter.name = "jupiter"
        jupiter.rotation = 0.415
        jupiter.orbit = 11.9
        jupiter.scale = 11.21
        jupiter.radius = 0.1730
        jupiter.angle = 3.4790
        planets[jupiter.name] = jupiter

        var saturn = Planet()
        saturn.path.addEllipse(rects[5])
        saturn.name = "saturn"
        saturn.rotation = 0.445
        saturn.orbit = 29.4
        saturn.scale = 9.45
        saturn.radius = 0.3188
        saturn.angle = 4.5538
        planets[saturn.name] = saturn

        var uranus = Planet()
        uranus.path.addEllipse(rects[6])
        uranus.name = "uranus"
        uranus.rotation = -0.720
        uranus.orbit = 83.7
        uranus.scale = 4.01
        uranus.radius = 0.6389
        uranus.angle = 0.3222
        planets[uranus.name] = uranus

        var neptune = Planet()
        neptune.path.addEllipse(rects[7])
        neptune.name = "neptune"
        neptune.rotation = 0.673
        neptune.orbit = 163.7
        neptune.scale = 3.88
        neptune.radius = 1.0
        neptune.angle = 5.8828
        planets[neptune.name] = neptune

        var pluto = Planet()
        pluto.path.addEllipse(rects[8])
        pluto.name = "pluto"
        pluto.rotation = 0.673
        pluto.orbit = 163.7
        pluto.scale = 0.186
        pluto.radius = 1.313
//        planets[pluto.name] = pluto

        var sun = Planet()
        sun.path.addEllipse(rects[9])
        sun.name = "sun"
        sun.rotation = 0
        sun.orbit = 0
        sun.scale = 1.0
        sun.radius = 0
        planets[sun.name] = sun
    }
}

public struct Planet {
    var path = Path()
    var cgpath: CGPath {
        return path.CGPath
    }
    var name = "earth"
    var sprite: SKSpriteNode {
        return SKSpriteNode(imageNamed: name)
    }
    var rotation: CGFloat = 1.0
    var orbit: CGFloat = 1.0
    var scale: CGFloat = 1.0
    var radius: CGFloat = 0.0253
    var angle: CGFloat = 0.0
}
