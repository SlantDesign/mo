//
//  GameViewController.swift
//  AsteroidSim
//
//  Created by travis on 2017-01-11.
//  Copyright © 2017 C4. All rights reserved.
//


import Foundation
import MO
import C4
import CocoaAsyncSocket
import UIKit
import SpriteKit
import GameplayKit

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let asteroid = PacketType(rawValue: 200000)
    static let asteroidCountReset = PacketType(rawValue: 200001)
    static let explodeAsteroid = PacketType(rawValue: 200002)
}

public protocol AsteroidBeltDelegate {
    func explodeAsteroid(tag: Int)
}

class AsteroidBelt: UniverseController, GCDAsyncSocketDelegate, AsteroidBeltDelegate {
    let socketManager = SocketManager.sharedManager
    let asteroidsView = SKView()
    var asteroidBeltScene: AsteroidBeltScene?
    var asteroidCount = 0

    private var timer: C4.Timer?

    override func setup() {
        asteroidsView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(asteroidsView)
        guard let scene = AsteroidBeltScene(fileNamed: "AsteroidBeltScene") else {
            print("Could not load AsteroidsScene")
            return
        }
        scene.scaleMode = .aspectFill
        asteroidsView.presentScene(scene)
        asteroidBeltScene = scene
        asteroidBeltScene?.asteroidBeltDelegate = self

        asteroidsView.ignoresSiblingOrder = true
        asteroidsView.showsFPS = true
        asteroidsView.showsNodeCount = true

        if SocketManager.sharedManager.deviceID == 18 {
            timer = C4.Timer(interval: 0.5) {
                self.sendCreateAsteroid()
            }
            timer?.start()
        }
    }

    func sendCreateAsteroid() {
        let point = CGPoint(x: frandom() * CGFloat(-frameCanvasWidth) - CGFloat(frameCanvasWidth/2), y: -view.frame.size.height/2.0 - 100)
        var data = Data()
        data.append(point)
        let packet = Packet(type: .asteroid, id: asteroidCount, payload: data)
        asteroidCount += 1
        if asteroidCount > 1000 {
            asteroidCount = 0
        }
        socketManager.broadcastPacket(packet)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.asteroid:
            createAsteroid(packet: packet)
        case PacketType.asteroidCountReset:
            asteroidCount = packet.id
        case PacketType.explodeAsteroid:
            asteroidBeltScene?.explodeAsteroid(tag: packet.id)
        default:
            break
        }
    }

    func createAsteroid(packet: Packet) {
        guard let d = packet.payload else {
            print("Asteroid packet did not have data.")
            return
        }

        var point = (d as NSData).bytes.bindMemory(to: CGPoint.self, capacity: d.count).pointee
        if SocketManager.sharedManager.deviceID == 17 {
            point.x += CGFloat(frameCanvasWidth)

        } else if SocketManager.sharedManager.deviceID == 19 {
            point.x -= CGFloat(frameCanvasWidth)
            point.y += 12.0
        }
        asteroidBeltScene?.createAsteroid(point: point, tag: packet.id)
    }

    func explodeAsteroid(tag: Int) {
        let packet = Packet(type: .explodeAsteroid, id: tag)
        socketManager.broadcastPacket(packet)
    }

    func frandom() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
