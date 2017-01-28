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
    static let comet = PacketType(rawValue: 300001)
}

public protocol CometSceneDelegate {
}

class Comet: UniverseController, GCDAsyncSocketDelegate, CometSceneDelegate {
    let socketManager = SocketManager.sharedManager
    let cometView = SKView()
    var cometScene: CometScene?

    override func setup() {
        cometView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(cometView)
        guard let scene = CometScene(fileNamed: "CometScene") else {
            print("Could not load CometScene")
            return
        }
        scene.scaleMode = .aspectFill
        cometView.presentScene(scene)
        cometScene = scene
        cometScene?.cometDelegate = self

        cometView.ignoresSiblingOrder = false
        cometView.showsFPS = true
        cometView.showsNodeCount = true
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.comet:
            createComet(packet: packet)
        default:
            break
        }
    }

    func createComet(packet: Packet) {
        guard let payload = packet.payload else {
            print("MO packet did not have data.")
            return
        }

        var index = 0

        let imageID = payload.extract(Int.self, at: index)
        index += MemoryLayout<Int>.size
        var position = payload.extract(CGPoint.self, at: index)

        let dx = CGFloat(packet.id - SocketManager.sharedManager.deviceID) * CGFloat(frameCanvasWidth)
        position.x += dx

        cometScene?.createMovingComet(imageID: imageID, at: position)
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
