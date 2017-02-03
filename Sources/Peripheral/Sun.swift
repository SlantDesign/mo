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
            handleSun(packet)
            break
        default:
            break
        }
    }

    func handleSun(_ packet: Packet) {
        guard let data = packet.payload else {
            print("Could not extract payload data")
            return
        }
        var index = 0
        let id = data.extract(Int.self, at: index)
        index += MemoryLayout<Int>.size
        var point = data.extract(CGPoint.self, at: index)
        index += MemoryLayout<CGPoint>.size
        let effectNameIndex = data.extract(Int.self, at: index)
        index += MemoryLayout<Int>.size
        let angle = data.extract(Int.self, at: index)

        if SocketManager.sharedManager.deviceID == packet.id {
            sunScene?.createEffect(nameIndex: effectNameIndex, at: point, angle: angle)
        } else if SocketManager.sharedManager.deviceID == id {
            let dx = CGFloat(packet.id - SocketManager.sharedManager.deviceID) * CGFloat(frameCanvasWidth)
            point.x += dx
            sunScene?.createEffect(nameIndex: effectNameIndex, at: point, angle: angle)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
