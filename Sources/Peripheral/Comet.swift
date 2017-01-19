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
    static let mo = PacketType(rawValue: 999999)
}

public protocol CometSceneDelegate {
    func fire()
}

class Comet: UniverseController, GCDAsyncSocketDelegate, CometSceneDelegate {
    let socketManager = SocketManager.sharedManager
    let moView = SKView()
    var cometScene: CometScene?

    func fire() {
        self.sendCreatePacket()
    }

    override func setup() {
        moView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(moView)
        guard let scene = CometScene(fileNamed: "CometScene") else {
            print("Could not load CometScene")
            return
        }
        scene.scaleMode = .aspectFill
        moView.presentScene(scene)
        cometScene = scene
        cometScene?.cometDelegate = self

        moView.ignoresSiblingOrder = true
        moView.showsFPS = true
        moView.showsNodeCount = true
    }

    func sendCreatePacket() {
        var data = Data()
        data.append(Point(-1, -1))
        let packet = Packet(type: .mo, id: 0, payload: data)
        socketManager.broadcastPacket(packet)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.mo:
            handleMessage(packet: packet)
        default:
            break
        }
    }

    func handleMessage(packet: Packet) {
        guard let d = packet.payload else {
            print("MO packet did not have data.")
            return
        }

        let p = (d as NSData).bytes.bindMemory(to: CGPoint.self, capacity: d.count).pointee
        //moScene.runSomeThing(point: p)
        print(p)
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
