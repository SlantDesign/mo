//
//  WorkSpace.swift
//  Peripheral
//
//  Created by travis on 2016-03-14.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import CocoaAsyncSocket
import CocoaLumberjack
import MO
import UIKit

public protocol SpiralUniverseDelegate {
    func shouldSendScrollData()
    func shouldSendCease()
}

class Resonate: UniverseController, GCDAsyncSocketDelegate, ScrollUniverseDelegate {
    let socketManager = SocketManager.sharedManager
    var scheduleViewController: ScheduleViewController?

    override func setup() {
        canvas.bounds.origin.x = 0
        initializeCollectionView()
    }

    override func load() {
        Schedule.shared
    }

    func initializeCollectionView() {
        let storyboard = UIStoryboard(name: "ScheduleViewController", bundle: nil)
        scheduleViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController
        scheduleViewController?.collectionView?.dataSource = Schedule.shared
        guard scheduleViewController != nil else {
            print("Collection view could not be instantiated from storyboard.")
            return
        }
        canvas.add(scheduleViewController?.collectionView)
        scheduleViewController?.collectionView?.contentOffset = CGPoint(x: CGFloat(SocketManager.sharedManager.deviceID-1) * 997.0 + 1, y: 0)
        scheduleViewController?.scrollUniverseDelegate = self
    }

    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case .scroll:
            guard let d = packet.data else {
                DDLogVerbose("Packet does not contain point data")
                return
            }

            let point = (d as NSData).bytes.bindMemory(to: CGPoint.self, capacity: d.count).pointee
            let interaction = RemoteInteraction(point: point, deviceID: packet.id, timestamp: CFAbsoluteTimeGetCurrent())
            scheduleViewController?.registerRemoteUserInteraction(interaction)

        case .resonateShape:
            guard let d = packet.data else {
                DDLogVerbose("Packet does not contain data")
                return
            }

            scheduleViewController?.generateShapeFromData(d)

        case .cease:
            scheduleViewController?.registerRemoteCease(packet.id)

        case .sync:
            scheduleViewController?.syncTimestamp = CFAbsoluteTimeGetCurrent()

        default:
            break
        }
    }

    func shouldSendScrollData() {
        var point = scheduleViewController!.collectionView!.contentOffset
        let data = NSMutableData()
        data.append(&point, length: MemoryLayout<CGPoint>.size)

        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: PacketType.scroll, id: deviceId, data: data as Data)
        socketManager.broadcastPacket(packet)
    }

    func shouldSendCease() {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: .cease, id: deviceId)
        socketManager.broadcastPacket(packet)
    }
}
