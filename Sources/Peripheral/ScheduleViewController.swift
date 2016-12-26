// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import C4
import CocoaLumberjack
import Foundation
import MO
import UIKit

public protocol ScrollUniverseDelegate: class {
    func shouldSendScrollData()
    func shouldSendCease()
}

open class ScheduleViewController: UICollectionViewController {
    let interactionTimeout = TimeInterval(5)
    var indicator: Shape!
    var scrollSource = ScrollSource.local
    var interactionsByID = [Int: RemoteInteraction]()
    var lastLocalInteractionTimestamp: TimeInterval?
    var interactionCeaseTimer: UIKit.Timer?
    weak var scrollUniverseDelegate: ScrollUniverseDelegate?
    var tap: UITapGestureRecognizer!
    var dx: CGFloat = 0.0
    var shapeTimer: C4.Timer!
    var syncTimestamp: TimeInterval = 0 {
        didSet {
            Schedule.shared.syncTimestamp = syncTimestamp
            guard let collectionView = collectionView else {
                return
            }
            for cell in collectionView.visibleCells {
                if let eventCell = cell as? EventCell {
                    eventCell.syncTimestamp = syncTimestamp
                }
            }
        }
    }

    override open func viewDidLoad() {
        collectionView?.register(EventCell.self, forCellWithReuseIdentifier: "EventCell")

        let id = SocketManager.sharedManager.deviceID
        dx = CGFloat(id-1) * CGFloat(frameCanvasWidth)

        let headerViewNib = UINib.init(nibName: "HourHeaderView", bundle: nil)
        collectionView?.register(headerViewNib, forSupplementaryViewOfKind: "HourHeaderView", withReuseIdentifier: "HourHeaderView")
        collectionView?.delegate = self
        ShapeLayer.disableActions = true
        ArtistView.shared.opacity = 0.0
        ShapeLayer.disableActions = false

        tap = UITapGestureRecognizer(target: self, action: #selector(generateShapeFromRecognizer))
        collectionView?.addGestureRecognizer(tap)
        tap.numberOfTapsRequired = 2
        tap.delaysTouchesBegan = true

        if let grs = collectionView?.gestureRecognizers {
            for i in 0..<grs.count {
                if i == 1 {
                    let g = grs[i]
                    g.addTarget(self, action: #selector(registerUserInteraction))
                }
            }
        }

        indicator = createScrollIndicator()
        indicator.center = Point(collectionView!.center)
        indicator.zPosition = Double(Int.max)
        collectionView?.add(indicator)

        shapeTimer = C4.Timer(interval: 28.0) {
            let x = random01() * frameCanvasWidth
            let y = random01() * Double(self.collectionView!.bounds.height)
            self.generateShapeAtPoint(Point(x+Double(self.collectionView!.contentOffset.x), y))
        }

        wait(Double(SocketManager.sharedManager.deviceID)) {
            self.shapeTimer.start()
        }
    }

    func generateShapeFromRecognizer(_ gr: UIGestureRecognizer) {
        var center = gr.location
        center.x += Double(collectionView!.contentOffset.x)
        generateShapeAtPoint(center)
    }

    open func generateShapeFromData(_ data: Data) {
        let shape = ResonateShapeGenerator.shared.rebuildShape(data)
        addShapeToBack(shape)

    }

    func addShapeToBack(_ shape: Gradient) {
        shape.zPosition = -1000
        collectionView?.add(shape)
        collectionView?.sendSubview(toBack: shape.view)
    }

    func generateShapeAtPoint(_ point: Point) {
        let shapeData: (Gradient, Data) = ResonateShapeGenerator.shared.createRandomShape(point)
        addShapeToBack(shapeData.0)

        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: PacketType.resonateShape, id: deviceId, data: shapeData.1 as Data)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let e = Schedule.shared.eventAt(indexPath)
        if e.type == "OverNight" || e.type == "Unknown" {
            return
        }
        ArtistView.shared.event = e
        collectionView.superview?.add(ArtistView.shared)
        ArtistView.shared.reveal()
    }

    override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var newOffset = scrollView.contentOffset
        if newOffset.x < 0 {
            newOffset.x += Schedule.shared.singleContentWidth
            scrollView.contentOffset = newOffset
        } else if newOffset.x > Schedule.shared.singleContentWidth {
            newOffset.x = 0
            scrollView.contentOffset = newOffset
        }

        let x = Double(scrollView.contentOffset.x / Schedule.shared.singleContentWidth)
        ShapeLayer.disableActions = true
        let a = max(x*768.0 - 5, 0) / 768.0
        let b = min(x*768.0 + 5, 768.0) / 768.0

        indicator.strokeStart = a
        indicator.strokeEnd = b

        indicator.center = Point(Double(scrollView.contentOffset.x+scrollView.frame.width/2.0), Double(scrollView.frame.height) - indicator.height)

        ShapeLayer.disableActions = false

        if scrollSource != .local {
            return
        }

        scrollUniverseDelegate?.shouldSendScrollData()
        lastLocalInteractionTimestamp = Date().timeIntervalSinceReferenceDate

        interactionCeaseTimer?.invalidate()
        interactionCeaseTimer = UIKit.Timer.scheduledTimer(timeInterval: interactionTimeout, target: self, selector: #selector(interactionTimedOut), userInfo: nil, repeats: false)
    }

    // MARK: RemoteInteraction

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
            let dID = SocketManager.sharedManager.deviceID - closest.deviceID
            let dx = CGFloat(dID) * CGFloat(frameCanvasWidth)
            let localOffset = CGPoint(x: dx + closest.point.x, y: 0)
            remoteScrollTo(localOffset)
        }
    }

    open func registerRemoteCease(_ id: Int) {
        interactionsByID[id] = nil
    }

    func remoteScrollTo(_ point: CGPoint) {
        if collectionView?.contentOffset == point {
            return
        }

        scrollSource = .remote
        collectionView?.setContentOffset(point, animated: false)

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

    func interactionTimedOut() {
        lastLocalInteractionTimestamp = nil
        scrollUniverseDelegate?.shouldSendCease()
    }

    func createScrollIndicator() -> Shape {
        let dx = Vector(x: 5, y: 0)
        let dxdy = Vector(x: 10, y: -5)

        var point = Point()
        let path = Path()

        while point.x <= 758.0 {
            path.moveToPoint(point)
            path.addLineToPoint(point + dxdy)
            point += dx
        }

        let indicator = Shape(path)
        indicator.frame = Rect(0, 0, 768, indicator.height)
        indicator.fillColor = clear
        indicator.lineWidth = 0.5
        indicator.strokeColor = white

        return indicator
    }
}
