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
            let point = UnsafePointer<CGPoint>(d.bytes).memory
            handleScroll(point)
        default:
            break
        }
    }

    func handleScroll(point: CGPoint) {
        if let s = currentUniverse as? Spiral {
            s.registerRemoteUserInteraction(point)
        }
    }

    var currentOffset = CGPointZero
    func shouldSendScrollData() {
        if let spiral = currentUniverse as? Spiral {
            if spiral.shouldReportContentOffset {
                var offset = spiral.scrollview.contentOffset
                if offset != currentOffset {
                    let data = NSMutableData()
                    data.appendBytes(&offset, length: sizeof(CGPoint))
                    let packet = Packet(type: PacketType.Scroll, id:  deviceId, data: data)
                    socketManager?.sendPacket(packet)
                    currentOffset = offset
                }
            }
        }
    }
}

