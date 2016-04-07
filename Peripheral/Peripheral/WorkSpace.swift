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

class WorkSpace: CanvasController, GCDAsyncSocketDelegate, ScrollUniverseDelegate {
    var socketManager: SocketManager?
    var currentUniverse: UniverseController?
    var scheduleViewController: ScheduleViewController?

    override func setup() {
        initializeSocketManager()
        initializeCollectionView()
    }

    func initializeCollectionView() {
        let storyboard = UIStoryboard(name: "ScheduleViewController", bundle: nil)
        scheduleViewController = storyboard.instantiateViewControllerWithIdentifier("ScheduleViewController") as? ScheduleViewController
        scheduleViewController?.collectionView?.dataSource = Schedule.shared
        guard scheduleViewController != nil else {
            print("Collection view could not be instantiated from storyboard.")
            return
        }
        canvas.add(scheduleViewController?.collectionView)
        scheduleViewController?.collectionView?.contentOffset = CGPoint(x: CGFloat(SocketManager.sharedManager.deviceID-1) * 997.0, y: 0)
        scheduleViewController?.scrollUniverseDelegate = self
    }

    func initializeSocketManager() {
        socketManager = SocketManager.sharedManager
        socketManager?.workspace = self
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
            scheduleViewController?.registerRemoteUserInteraction(interaction)

        case .Cease:
            scheduleViewController?.registerRemoteCease(packet.id)
        default:
            break
        }
    }

    var currentOffset = CGPointZero
    func shouldSendScrollData() {
        var point = scheduleViewController!.collectionView!.contentOffset
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
