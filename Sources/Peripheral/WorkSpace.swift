// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import CocoaLumberjack
import C4
import Foundation
import MO
import UIKit

class WorkSpace: CanvasController {
    var socketManager: SocketManager?
    var currentUniverse: UniverseController?
    var syncTimestamp: TimeInterval = 0
    var loading: View!
    var universe = Universe()

    var preparing: Bool = false

    override func setup() {
        initializeSocketManager()
        currentUniverse = universe
        canvas.add(currentUniverse?.canvas)
    }

    func prepareUniverse() {
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        backgroundQueue.async {
        }
    }

    func initializeSocketManager() {
        socketManager = SocketManager.sharedManager
        socketManager?.workspace = self
    }

    func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.switchUniverse:
            if let name = extractNewUniverseName(packet.payload) {
                //FIXME: This is where we should switch between universes, initiating some kind of 
                currentUniverse = selectUniverse(name)
            }
        default:
            currentUniverse?.receivePacket(packet)
       }
    }

    func extractNewUniverseName(_ data: Data?) -> String? {
        if let d = data,
        let name = NSString(data: d as Data, encoding: String.Encoding.utf8.rawValue) {
            return name as String
        }
        return nil
    }

    func selectUniverse(_ name: String) -> UniverseController? {
        switch name {
        case "Universe":
            return universe
        default:
            return nil
        }
    }

    func switchUniverse(_ newUniverse: UniverseController) {
        UIView.transition(from: currentUniverse!.canvas.view, to: newUniverse.canvas.view, duration: 0.25, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.transitionCrossDissolve]) { (_) -> Void in
            self.currentUniverse = newUniverse
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
