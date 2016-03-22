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
}

class WorkSpace: CanvasController, GCDAsyncSocketDelegate, SpiralUniverseDelegate {
    let deviceId = NSUserDefaults.standardUserDefaults().integerForKey("deviceID")
    var socketManager: SocketManager?
    var currentUniverse: UniverseController?

    override func setup() {
        let schedule = Schedule()
    }

    func initializeSocketManager() {
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

            let interaction = UnsafePointer<RemoteInteraction>(d.bytes).memory
            if let s = currentUniverse as? Spiral {
                s.registerRemoteUserInteraction(interaction)
            }
            
        default:
            break
        }
    }

    var currentOffset = CGPointZero
    func shouldSendScrollData() {
        if let spiral = currentUniverse as? Spiral {
            var interaction = RemoteInteraction(point: spiral.scrollview.contentOffset, timestamp: NSDate().timeIntervalSinceReferenceDate, deviceID: deviceId)
            let data = NSMutableData()
            data.appendBytes(&interaction, length: sizeof(RemoteInteraction))
            let packet = Packet(type: PacketType.Scroll, id:  deviceId, data: data)
            socketManager?.sendPacket(packet)
        }
    }
}
