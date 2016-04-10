//
//  WorkSpace.swift
//  Peripheral
//
//  Created by travis on 2016-04-07.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import CocoaLumberjack
import C4

class WorkSpace: CanvasController {
    var socketManager: SocketManager?
    var currentUniverse: UniverseController?
    var resonate: Resonate?
    var status: Status?
    var tap: UITapGestureRecognizer!
    var syncTimestamp: NSTimeInterval = 0

    override func setup() {
        initializeSocketManager()

        status = Status()
        currentUniverse = status
        canvas.add(currentUniverse?.canvas)

        tap = canvas.addTapGestureRecognizer { locations, center, state in
            self.prepareUniverse()
        }
    }

    func prepareUniverse() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.resonate = Resonate()
            dispatch_async(dispatch_get_main_queue()) {
                self.currentUniverse?.unload()
                self.view.removeGestureRecognizer(self.tap)
                self.switchUniverse(self.resonate!)
            }
        }
    }

    func initializeSocketManager() {
        socketManager = SocketManager.sharedManager
        socketManager?.workspace = self
    }

    func receivePacket(packet: Packet) {
        switch packet.packetType {
        case .SwitchUniverse:
            if let name = extractNewUniverseName(packet.data) {
                selectUniverse(name)
            }
        default:
            currentUniverse?.receivePacket(packet)
       }
    }

    func extractNewUniverseName(data: NSData?) -> String? {
        if let d = data,
        let name = NSString(data: d, encoding: NSUTF8StringEncoding) {
            return name as String
        }
        return nil
    }

    func selectUniverse(name: String) -> UniverseController? {
        switch name {
        case "Resonate":
            return resonate
        default:
            return nil
        }
    }

    func switchUniverse(newUniverse: UniverseController) {
        UIView.transitionFromView(currentUniverse!.canvas.view, toView: newUniverse.canvas.view, duration: 0.5, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.TransitionCrossDissolve]) { (Bool) -> Void in
            self.currentUniverse?.unload()
            self.currentUniverse = newUniverse
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
