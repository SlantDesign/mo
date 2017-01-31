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
    static let comet = PacketType(rawValue: 200001)
}

class AsteroidBelt: UniverseController, GCDAsyncSocketDelegate {
    static let primaryDevice = 18
    let socketManager = SocketManager.sharedManager
    let asteroidBeltView = SKView()
    var asteroidBeltScene: AsteroidBeltScene?
    var asteroidCount = 0

    private var timer: C4.Timer?

    override func setup() {
        asteroidBeltView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(asteroidBeltView)

        guard let scene = AsteroidBeltScene(fileNamed: "AsteroidBeltScene") else {
            print("Could not load AsteroidsScene")
            return
        }
        scene.scaleMode = .aspectFill
        asteroidBeltView.presentScene(scene)
        asteroidBeltScene = scene

        asteroidBeltView.ignoresSiblingOrder = false
        asteroidBeltView.showsFPS = true
        asteroidBeltView.showsNodeCount = true

        if SocketManager.sharedManager.deviceID == AsteroidBelt.primaryDevice {
            timer = C4.Timer(interval: 0.5) {
                self.sendCreateAsteroid()
            }
            timer?.start()
        }
    }

    //This method is called only on a designated device (see setup where: `SocketManager.sharedManager.deviceID == 18`)
    func sendCreateAsteroid() {
        let point = CGPoint(x: frandom() * CGFloat(-frameCanvasWidth) - CGFloat(frameCanvasWidth/2), y: -view.frame.size.height/2.0 - 100)
        var data = Data()
        data.append(point)
        data.append(asteroidCount)
        asteroidCount += 1
        if asteroidCount == Int.max { asteroidCount = 0 }
        let packet = Packet(type: .asteroid, id: asteroidCount, payload: data)
        socketManager.broadcastPacket(packet)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.asteroid:
            handleAddAsteroid(packet: packet)
        case PacketType.comet:
            handleAddComet(packet: packet)
        default:
            break
        }
    }

    func handleAddComet(packet: Packet) {
        guard let d = packet.payload else {
            print("Comet packet did not have data.")
            return
        }

        var index = 0
        let identifier = d.extract(Int.self, at: index)
        index += MemoryLayout<Int>.size
        var position = d.extract(CGPoint.self, at: index)

        let offset = packet.id - SocketManager.sharedManager.deviceID
        position.x += CGFloat(frameCanvasWidth * Double(offset))

        asteroidBeltScene?.removeAsteroidAddComet(identifier: identifier, position: position)
    }

    func handleAddAsteroid(packet: Packet) {
        guard let d = packet.payload else {
            print("Asteroid packet did not have data.")
            return
        }

        var point = (d as NSData).bytes.bindMemory(to: CGPoint.self, capacity: d.count).pointee

        let offset = AsteroidBelt.primaryDevice - SocketManager.sharedManager.deviceID

        //asteroids are only visible on 3 devices, so don't add them if they wouldn't ever appear
        if abs(offset) <= 1 {
            point.x += CGFloat(frameCanvasWidth * Double(offset))
            asteroidBeltScene?.createAsteroid(point: point, identifier: packet.id)
        }
    }

    func frandom() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
