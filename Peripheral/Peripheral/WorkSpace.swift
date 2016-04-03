//
//  WorkSpace.swift
//  Peripheral
//
//  Created by travis on 2016-03-14.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit
import CocoaAsyncSocket
import CocoaLumberjack

public protocol SpiralUniverseDelegate {
    func shouldSendScrollData()
    func shouldSendCease()
}

class WorkSpace: CanvasController, GCDAsyncSocketDelegate, SpiralUniverseDelegate {
    var socketManager: SocketManager?
    var currentUniverse: UniverseController?

    override func setup() {
        socketManager = SocketManager.sharedManager
        socketManager?.workspace = self
        
        let s = Spiral()
        s.spiralUniverseDelegate = self
        currentUniverse = s
        canvas.add(currentUniverse?.canvas)
    }

    func receivePacket(packet: Packet) {
        switch packet.packetType {
        case .Scroll:
            guard let d = packet.data else {
                DDLogVerbose("Packet does not contain point data")
                return
            }

            let point = UnsafePointer<CGPoint>(d.bytes).memory
            let interaction = RemoteInteraction(point: point, deviceID: packet.id, timestamp: CFAbsoluteTimeGetCurrent())
            if let s = currentUniverse as? Spiral {
                s.registerRemoteUserInteraction(interaction)
            }

        case .Cease:
            if let s = currentUniverse as? Spiral {
                s.registerRemoteCease(packet.id)
            }

        default:
            break
        }
    }

    var currentOffset = CGPointZero
    func shouldSendScrollData() {
        guard let spiral = currentUniverse as? Spiral else {
            return
        }

        var point = spiral.scrollview.contentOffset
        let data = NSMutableData()
        data.appendBytes(&point, length: sizeof(CGPoint))

        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: PacketType.Scroll, id: deviceId, data: data)
        socketManager?.broadcastPacket(packet)
    }

    func shouldSendCease() {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: .Cease, id: deviceId)
        socketManager?.broadcastPacket(packet)
    }
}
