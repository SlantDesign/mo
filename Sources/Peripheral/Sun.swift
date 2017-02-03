//
//  Sun.swift
//  MO
//
//  Created by travis on 2017-02-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import UIKit
import SpriteKit

extension PacketType {
    static let sun = PacketType(rawValue: 700000)
}

class Sun: UniverseController, GCDAsyncSocketDelegate {
    static let primaryDevice = 18
    let socketManager = SocketManager.sharedManager
    let sunView = SKView()
    var sunScene: SunScene?

    private var timer: C4.Timer?

    //creates the asteroidBelt view and sets up a timer from the primary device
    override func setup() {
        sunView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(sunView)

        guard let scene = SunScene(fileNamed: "SunScene") else {
            print("Could not load SunScene")
            return
        }
        scene.scaleMode = .aspectFill
        sunView.presentScene(scene)
        sunScene = scene

        sunView.ignoresSiblingOrder = false
        sunView.showsFPS = true
        sunView.showsNodeCount = true

//        canvas.addTapGestureRecognizer { _, point, _ in
//            self.sunScene?.randomEffect(at: self.convertToSceneKitCoordinates(point))
//        }
    }

    func convertToSceneKitCoordinates(_ point: Point) -> CGPoint {
        let localized = point - Point(self.dx, 0)
        let normalized = localized - Vector(self.canvas.center)
        return CGPoint(x: CGFloat(normalized.x), y: -CGFloat(normalized.y))
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.sun:
            break
        default:
            break
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
