//
//  CircularTimeline.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import C4
import MO
import CocoaAsyncSocket

extension PacketType {
    static let adjustTimeline = PacketType(rawValue: 200000)
}

class CircularTimeline: UniverseController, GCDAsyncSocketDelegate {
    let socketManager = SocketManager.sharedManager
    let img = TimelineImage("chop")!
    var t = Transform()
    var pan: UIPanGestureRecognizer?
    var rotate: UIPanGestureRecognizer?
    let angle = M_PI_4
    var images = [TimelineImage]()
    let rotationContainer = View(frame: Rect(0, 0, 1200, 1200))

    override func setup() {
        for _ in 0..<300 {
            let choice = round(random01())
            let img = TimelineImage(choice == 0 ? "chop" : "rockies")!
            img.center = canvas.center
            img.constrainsProportions = true
            img.width = 100.0
            img.angle = random01() * 2 * M_PI
            img.dxdy = rotationContainer.bounds.center
            img.baseWidth = self.canvas.width
            img.basedt = random01()
            img.update(displacement: 0)
            images.append(img)
            let neighbourOffset = Double(17 - SocketManager.sharedManager.deviceID) * frameCanvasWidth
            rotationContainer.center = Point(canvas.center.x + dx + neighbourOffset, canvas.height)
            rotationContainer.add(img)
        }
        canvas.add(rotationContainer)

        pan = canvas.addPanGestureRecognizer { _, center, translation, _, _ in
            self.adjust(translation: translation)
        }
    }

    func adjust(translation: Vector) {
        for img in self.images {
            img.update(displacement: translation.y)
        }
        rotationContainer.rotation += translation.x / self.canvas.width
        self.pan?.setTranslation(CGPoint(), in: nil)
    }

    override func receivePacket(_ packet: Packet) {

    }
}
