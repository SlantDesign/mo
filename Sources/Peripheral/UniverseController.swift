//  Copyright © 2015 C4. All rights reserved.

import C4
import MO
import UIKit

let frameGap = 229.0
let frameCanvasWidth = 997.0

open class UniverseController : CanvasController {
    open override func viewDidLoad() {
        canvas.bounds.origin.x = dx
        canvas.backgroundColor = clear
        super.viewDidLoad()
    }
    
    var physicalFrame : Rect {
        get {
            return Rect(dx-frameGap/2.0,0,frameCanvasWidth,1024)
        }
    }

    func load() {

    }

    var accesPoints : Int {
        get {
            return 5
        }
    }
    
    var dx : Double {
        get {
            let id = SocketManager.sharedManager.deviceID
            return Double(id-1) * frameCanvasWidth - frameGap/2.0
        }
    }

    open func receivePacket(_ packet: Packet) {
        
    }

    open func handleGesture(_ gesture: Gesture) {
        
    }
    
    open func unload() {
        
    }
}
