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
    var parallax = Parallax()

    var preparing: Bool = false

    override func setup() {
        initializeSocketManager()

        parallax.initializeCollectionView()
        currentUniverse = parallax
        canvas.add(currentUniverse?.canvas)
    }

    func showLoading() {
        ShapeLayer.disableActions = true
        loading = View(frame: Rect(0, 0, 50, 50))
        loading.rotation += -M_PI_2
        let loader = Circle(center: loading.center, radius: loading.width/2.0)
        loader.fillColor = clear
        loader.strokeColor = white
        loader.lineCap = .Round
        loader.strokeEnd = 0.0
        loading.add(loader)
        ShapeLayer.disableActions = false

        let a = ViewAnimation(duration: 1.0) {
            loader.strokeEnd = 1.0
        }

        let b = ViewAnimation(duration: 1.0) {
            loader.strokeStart = 1.0
        }
        b.delay = 0.5

        let c = ViewAnimation(duration: 0.0) {
            loader.strokeEnd = 0.0
            loader.strokeStart = 0.0
        }
        c.delay = 1.25

        let seq = ViewAnimationGroup(animations: [a, b, c])
        seq.addCompletionObserver {
            seq.animate()
        }
        seq.animate()
        loading.center = Point(canvas.center.x, canvas.height * 0.75)
        self.canvas.add(loading)
        print("loading")
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
        case "Parallax":
            return parallax
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
