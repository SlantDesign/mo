//
//  SlidingScrollview.swift
//  M-O
//
//  Created by travis on 2016-03-11.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit
import CocoaLumberjack

public class Spiral : UniverseController {
    let scrollViewRotation = -0.01
    let pageCount = 60
    let interactionTimeout = NSTimeInterval(10)

    enum ScrollSource {
        case Local
        case Remote
    }
    var scrollSource = ScrollSource.Local

    let container = View()
    let scrollview = InfiniteScrollView()
    let interaction = InfiniteScrollView()
    var primaryCenter = Point()
    var spiralUniverseDelegate: SpiralUniverseDelegate?

    var interactionsByID = [Int: RemoteInteraction]()
    var lastLocalInteractionTimestamp: NSTimeInterval?
    weak var interactionCeaseTimer: NSTimer?

    public override func setup() {

        container.frame = canvas.frame
        scrollview.frame = view.frame
        scrollview.userInteractionEnabled = false
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
        interaction.layer.borderColor = UIColor.redColor().CGColor
        interaction.layer.borderWidth = 1.0
        interaction.contentSize = CGSize(width: interaction.frame.width * CGFloat(pageCount + 1), height: 1)

        interaction.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)

        interaction.transform = CGAffineTransformMakeRotation(CGFloat(scrollViewRotation))

        var p = canvas.center
        p.x += dx
        interaction.center = CGPoint(p)
        canvas.add(interaction)

        if let grs = interaction.gestureRecognizers {
            for g in grs {
                g.addTarget(self, action: #selector(Spiral.registerUserInteraction(_:)))
            }
        }
    }

    func createViewAtIndex(index: Int) -> View {
        let v = View(frame: canvas.frame)
        v.backgroundColor = colorAtIndex(index)

        let label = TextShape(text: "\(index)")
        label?.fillColor = white
        label?.center = v.center
        v.add(label)

        v.origin = Point(canvas.width * Double(index), 0)

        return v
    }

    func colorAtIndex(index: Int) -> Color {
        let c1 = C4Pink
        let c2 = C4Blue
        let vA = Vector(x: c1.red, y: c1.green, z: c1.blue)
        let vB = Vector(x: c2.red, y: c2.green, z: c2.blue)
        let t = Double(index) / Double(pageCount)
        let vC = vA + (vB - vA) * t
        return Color(red: vC.x, green: vC.y, blue: vC.z, alpha: 1.0)
    }

    public var shouldReportScroll: Bool {
        return scrollSource == .Local
    }

    public func registerUserInteraction(gestureRecognizer: UIGestureRecognizer) {
        scrollSource = .Local
    }

    public func registerRemoteUserInteraction(interaction: RemoteInteraction) {
        interactionsByID[interaction.deviceID] = interaction

        let currentTimestamp = NSDate().timeIntervalSinceReferenceDate
        if let timestamp = lastLocalInteractionTimestamp where currentTimestamp - timestamp < interactionTimeout {
            // Local interactions trump remote ones
            // TODO: maybe start moving slowly as time goes by?
            return
        }

        if let closest = pickClosestInteraction() {
            remoteScrollTo(closest.point)
        }
    }

    public func registerRemoteCease(id: Int) {
        interactionsByID[id] = nil
    }

    func remoteScrollTo(point: CGPoint) {
        if scrollview.contentOffset == point {
            return
        }

        scrollSource = .Remote
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

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if scrollSource != .Local {
            return
        }

        let normalOffset = (interaction.contentOffset.x / interaction.contentSize.width)
        let targetOffset = normalOffset * scrollview.contentSize.width
        if scrollview.contentOffset.x != targetOffset {
            scrollview.contentOffset = CGPoint(x: targetOffset,y: 0)
            let y = primaryCenter.y + map(Double(normalOffset), min: 0, max: 1, toMin: -120, toMax: 120)
            container.center.y = y
            spiralUniverseDelegate?.shouldSendScrollData()
        }

        lastLocalInteractionTimestamp = NSDate().timeIntervalSinceReferenceDate

        interactionCeaseTimer?.invalidate()
        interactionCeaseTimer = NSTimer.scheduledTimerWithTimeInterval(interactionTimeout, target: self, selector: #selector(interactionTimedOut), userInfo: nil, repeats: false)
    }

    func interactionTimedOut() {
        lastLocalInteractionTimestamp = nil
        spiralUniverseDelegate?.shouldSendCease()
    }
}
