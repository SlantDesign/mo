//
//  Cassini.swift
//  MO
//
//  Created by travis on 2017-02-04.
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
    static let cassini = PacketType(rawValue: 110000)
}

class Cassini: UniverseController, GCDAsyncSocketDelegate {
    static let primaryDevice = 17
    let cassiniView = SKView()
    var cassiniScene: CassiniScene?

    override func setup() {
        cassiniView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        canvas.add(cassiniView)

        guard let scene = CassiniScene(fileNamed: "CassiniScene") else {
            print("Could not load CassiniScene")
            return
        }
        scene.scaleMode = .aspectFill
        cassiniView.presentScene(scene)
        cassiniScene = scene

        cassiniView.ignoresSiblingOrder = false
        cassiniView.showsFPS = true
        cassiniView.showsNodeCount = true
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.cassini:
            guard let payload = packet.payload else {
                print("Couldn't extract payload")
                return
            }
            let point = payload.extract(CGPoint.self, at: 0)
            cassiniScene?.transmit(target: convertFromPrimaryDeviceCoordinates(point))
            break
        default:
            break
        }
    }

    func convertFromPrimaryDeviceCoordinates(_ point: CGPoint) -> CGPoint {
        var dx = CGFloat(Cassini.primaryDevice - SocketManager.sharedManager.deviceID)
        dx *= CGFloat(frameCanvasWidth)
        return CGPoint(x: point.x + dx, y: point.y)
    }

    //This is how you send a packet, with no data
    func send(type: PacketType) {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: type, id: deviceId)
        SocketManager.sharedManager.broadcastPacket(packet)
    }
}
