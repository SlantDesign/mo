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
    static let explode = PacketType(rawValue: 200001)
}

class Asteroids: UniverseController, GCDAsyncSocketDelegate {
    let socketManager = SocketManager.sharedManager
    let asteroidsView = SKView()
    private var timer: C4.Timer?

    override func setup() {
        asteroidsView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(asteroidsView)
        guard let scene = AsteroidsScene(fileNamed: "AsteroidsScene") else {
            print("Could not load AsteroidsScene")
            return
        }

        scene.scaleMode = .aspectFill
        asteroidsView.presentScene(scene)
        asteroidsView.ignoresSiblingOrder = true
        asteroidsView.showsFPS = true
        asteroidsView.showsNodeCount = true

        timer = C4.Timer(interval: 0.25) {
            self.sendCreateAsteroid()
        }
        timer?.start()
    }

    func sendCreateAsteroid() {
        let point = CGPoint(x: frandom() * -self.view.frame.size.width , y: -self.view.frame.size.height / 2.0 - 100.0)
        let deviceId = SocketManager.sharedManager.deviceID
        var data = Data()
        data.append(point)
        let packet = Packet(type: .asteroid, id: deviceId, payload: data)
        socketManager.broadcastPacket(packet)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.asteroid:
            createAsteroid(packet: packet)
        default:
            break
        }
    }

    func createAsteroid(packet: Packet) {
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
