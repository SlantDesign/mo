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
    var syncTimestamp: TimeInterval = 0
    var loading: View!

    var preparing: Bool = false

    override func setup() {
        initializeSocketManager()

        status = Status()
        currentUniverse = status
        canvas.add(currentUniverse?.canvas)

        tap = canvas.addTapGestureRecognizer { locations, center, state in
            if !self.preparing {
                self.preparing = true
                self.showLoading()
                self.prepareUniverse()
            }
        }
    }

    func showLoading() {
        ShapeLayer.disableActions = true
        loading = View(frame: Rect(0,0,50,50))
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

        let seq = ViewAnimationGroup(animations: [a,b,c])
        seq.addCompletionObserver {
            seq.animate()
        }
        seq.animate()
        loading.center = Point(canvas.center.x, canvas.height * 0.75)
        self.canvas.add(loading)
        print("loading")
    }

    func prepareUniverse() {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            self.resonate = Resonate()
            self.resonate?.load()
            DispatchQueue.main.async(execute: { () -> Void in
                self.canvas.remove(self.loading)
                self.preparing = false
                self.loading = nil
                self.currentUniverse?.unload()
                self.view.removeGestureRecognizer(self.tap)
                self.switchUniverse(self.resonate!)
            })
        })
    }

    func initializeSocketManager() {
        socketManager = SocketManager.sharedManager
        socketManager?.workspace = self
    }

    func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case .switchUniverse:
            if let name = extractNewUniverseName(packet.data as Data?) {
                selectUniverse(name)
            }
        default:
            currentUniverse?.receivePacket(packet)
       }
    }

    func extractNewUniverseName(_ data: Data?) -> String? {
        if let d = data,
        let name = NSString(data: d, encoding: String.Encoding.utf8.rawValue) {
            return name as String
        }
        return nil
    }

    func selectUniverse(_ name: String) -> UniverseController? {
        switch name {
        case "Resonate":
            return resonate
        default:
            return nil
        }
    }

    func switchUniverse(_ newUniverse: UniverseController) {
        UIView.transition(from: currentUniverse!.canvas.view, to: newUniverse.canvas.view, duration: 0.25, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.transitionCrossDissolve]) { (Bool) -> Void in
            self.currentUniverse = newUniverse
        }
    }
}
