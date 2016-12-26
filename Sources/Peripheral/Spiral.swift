// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import C4
import UIKit
import CocoaLumberjack

enum ScrollSource {
    case local
    case remote
}

open class Spiral: UniverseController {
    let scrollViewRotation = -0.01
    let pageCount = 60
    let interactionTimeout = TimeInterval(10)

    var scrollSource = ScrollSource.local

    let container = View()
    let scrollview = InfiniteScrollView()
    let interaction = InfiniteScrollView()
    var primaryCenter = Point()
    weak var spiralUniverseDelegate: SpiralUniverseDelegate?

    var interactionsByID = [Int: RemoteInteraction]()
    var lastLocalInteractionTimestamp: TimeInterval?
    var interactionCeaseTimer: UIKit.Timer?

    open override func setup() {

        container.frame = canvas.frame
        scrollview.frame = view.frame
        scrollview.isUserInteractionEnabled = false
        container.add(scrollview)
        canvas.add(container)

        container.rotation = scrollViewRotation
        container.masksToBounds = false
        container.center.x -= 997
        primaryCenter = container.center
        scrollview.clipsToBounds = false

        for i in 0..<pageCount {
            let view = createViewAtIndex(i)
            scrollview.add(view)
        }

        scrollview.contentSize = CGSize(width: scrollview.frame.width * CGFloat(pageCount + 1), height: 1)

        interaction.frame = CGRect(inset(canvas.frame, dx: -canvas.width * 0.22, dy: -canvas.height * 0.11))
        interaction.layer.borderColor = UIColor.red.cgColor
        interaction.layer.borderWidth = 1.0
        interaction.contentSize = CGSize(width: interaction.frame.width * CGFloat(pageCount + 1), height: 1)

        interaction.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)

        interaction.transform = CGAffineTransform(rotationAngle: CGFloat(scrollViewRotation))

        var p = canvas.center
        p.x += dx
        interaction.center = CGPoint(p)
        canvas.add(interaction)

        if let grs = interaction.gestureRecognizers {
            for g in grs {
                g.addTarget(self, action: #selector(Spiral.registerUserInteraction(_ :)))
            }
        }
    }

    func createViewAtIndex(_ index: Int) -> View {
        let v = View(frame: canvas.frame)
        v.backgroundColor = colorAtIndex(index)

        let label = TextShape(text: "\(index)")
        label?.fillColor = white
        label?.center = v.center
        v.add(label)

        v.origin = Point(canvas.width * Double(index), 0)

        return v
    }

    func colorAtIndex(_ index: Int) -> Color {
        let c1 = C4Pink
        let c2 = C4Blue
        let vA = Vector(x: c1.red, y: c1.green, z: c1.blue)
        let vB = Vector(x: c2.red, y: c2.green, z: c2.blue)
        let t = Double(index) / Double(pageCount)
        let vC = vA + (vB - vA) * t
        return Color(red: vC.x, green: vC.y, blue: vC.z, alpha: 1.0)
    }

    open var shouldReportScroll: Bool {
        return scrollSource == .local
    }

    open func registerUserInteraction(_ gestureRecognizer: UIGestureRecognizer) {
        scrollSource = .local
    }

    open func registerRemoteUserInteraction(_ interaction: RemoteInteraction) {
        interactionsByID[interaction.deviceID] = interaction

        let currentTimestamp = Date().timeIntervalSinceReferenceDate
        if let timestamp = lastLocalInteractionTimestamp, currentTimestamp - timestamp < interactionTimeout {
            // Local interactions trump remote ones
            // TODO: maybe start moving slowly as time goes by?
            return
        }

        if let closest = pickClosestInteraction() {
            remoteScrollTo(closest.point)
        }
    }

    open func registerRemoteCease(_ id: Int) {
        interactionsByID[id] = nil
    }

    func remoteScrollTo(_ point: CGPoint) {
        if scrollview.contentOffset == point {
            return
        }

        scrollSource = .remote
        scrollview.contentOffset = point

        let normalOffset = (scrollview.contentOffset.x / scrollview.contentSize.width)
        let targetOffset = normalOffset * interaction.contentSize.width
        interaction.contentOffset = CGPoint(x: targetOffset, y: 0)

        let y = primaryCenter.y + map(Double(normalOffset), min: 0, max: 1, toMin: -120, toMax: 120)
        container.center.y = y
    }

    func pickClosestInteraction() -> RemoteInteraction? {
        let deviceID = SocketManager.sharedManager.deviceID
        let maxDeviceID = SocketManager.sharedManager.maxDeviceID

        var minDistance = 1000
        var minInteraction: RemoteInteraction?
        for (_, interaction) in interactionsByID {
            // Ignore stale interactions
            if interaction.deviceID <= 0 || CFAbsoluteTimeGetCurrent() - interaction.timestamp > 60 {
                DDLogWarn("Ignoring stale interaction \(interaction.deviceID)")
                continue
            }

            let diff = abs(interaction.deviceID - deviceID)
            let d = min(diff, maxDeviceID - diff)
            if d < minDistance {
                minDistance = d
                minInteraction = interaction
            }
        }

        return minInteraction
    }

    func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        if scrollSource != .local {
            return
        }

        let normalOffset = (interaction.contentOffset.x / interaction.contentSize.width)
        let targetOffset = normalOffset * scrollview.contentSize.width
        if scrollview.contentOffset.x != targetOffset {
            scrollview.contentOffset = CGPoint(x: targetOffset, y: 0)
            let y = primaryCenter.y + map(Double(normalOffset), min: 0, max: 1, toMin: -120, toMax: 120)
            container.center.y = y
            spiralUniverseDelegate?.shouldSendScrollData()
        }

        lastLocalInteractionTimestamp = Date().timeIntervalSinceReferenceDate

        interactionCeaseTimer?.invalidate()
        interactionCeaseTimer = UIKit.Timer.scheduledTimer(timeInterval: interactionTimeout, target: self, selector: #selector(interactionTimedOut), userInfo: nil, repeats: false)
    }

    func interactionTimedOut() {
        lastLocalInteractionTimestamp = nil
        spiralUniverseDelegate?.shouldSendCease()
    }
}
