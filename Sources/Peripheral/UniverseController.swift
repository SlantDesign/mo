// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import C4
import MO
import UIKit

let frameGap = 229.0
let frameCanvasWidth = 997.0

extension PacketType {

}

open class UniverseController: CanvasController {
    open override func viewDidLoad() {
        canvas.bounds.origin.x = dx
        canvas.backgroundColor = clear
        super.viewDidLoad()
    }

    var physicalFrame: Rect {
        return Rect(dx-frameGap/2.0, 0, frameCanvasWidth, 1024)
    }

    func load() {

    }

    var accesPoints: Int {
        return 5
    }

    var dx: Double {
        let id = SocketManager.sharedManager.deviceID
        return Double(id-1) * frameCanvasWidth - frameGap/2.0
    }

    open func receivePacket(_ packet: Packet) {

    }

    open func handleGesture(_ gesture: Gesture) {

    }

    open func unload() {

    }
}
