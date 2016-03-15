//
//  WorkSpace.swift
//  Peripheral
//
//  Created by travis on 2016-03-14.
//  Copyright © 2016 C4. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class WorkSpace: CanvasController, GCDAsyncSocketDelegate, UIScrollViewDelegate {
    let deviceId = NSUserDefaults.standardUserDefaults().integerForKey("deviceID")
    var socketManager: SocketManager?
    var currentUniverse: UniverseController?

    override func setup() {
        socketManager = SocketManager.sharedManager
        currentUniverse = Spiral()
        canvas.add(currentUniverse?.canvas)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let spiral = currentUniverse as? Spiral {
            if spiral.shouldReportContentOffset {
                var offset = spiral.interaction.contentOffset
                let data = NSMutableData()
                data.appendBytes(&offset, length: sizeof(CGPoint))
                let packet = Packet(type: PacketType.Scroll, message: PacketMessage.None, id:  deviceId, data: data)
                socketManager?.sendPacket(packet)
            }
        }
    }
}

