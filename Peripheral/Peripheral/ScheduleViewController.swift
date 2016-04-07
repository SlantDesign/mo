//
//  ScheduleViewController.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import UIKit
import C4
import CocoaLumberjack

public protocol ScrollUniverseDelegate {
    func shouldSendScrollData()
    func shouldSendCease()
}

public class ScheduleViewController: UICollectionViewController {
    let interactionTimeout = NSTimeInterval(5)
    var scrollSource = ScrollSource.Local
    var interactionsByID = [Int: RemoteInteraction]()
    var lastLocalInteractionTimestamp: NSTimeInterval?
    weak var interactionCeaseTimer: NSTimer?
    var scrollUniverseDelegate: ScrollUniverseDelegate?

    var dx : CGFloat = 0.0
    let indicator = Circle(center: Point(0,1014), radius: 5)

    override public func viewDidLoad() {
        collectionView?.registerClass(EventCell.self, forCellWithReuseIdentifier: "EventCell")

        let id = SocketManager.sharedManager.deviceID
        dx = CGFloat(id-1) * CGFloat(frameCanvasWidth)

        let headerViewNib = UINib.init(nibName: "HourHeaderView", bundle: nil)
        collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: "HourHeaderView", withReuseIdentifier: "HourHeaderView")
        collectionView?.delegate = self
        ShapeLayer.disableActions = true
        indicator.lineWidth = 0.0
        indicator.zPosition = Double(Int.max)
        collectionView?.add(indicator)
        ArtistView.shared.opacity = 0.0
        ShapeLayer.disableActions = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(generateShapeFromTap))
        collectionView?.addGestureRecognizer(tap)

        if let grs = collectionView?.gestureRecognizers {
            for g in grs {
                g.addTarget(self, action: #selector(ScheduleViewController.registerUserInteraction(_:)))
            }
        }
    }

    func generateShapeFromTap(tap: UITapGestureRecognizer) {
        var center = tap.location
        center.x += Double(collectionView!.contentOffset.x)
        generateShapeAtPoint(center)
    }

    func generateShapeAtPoint(point: Point) {
        let shapeData: (Gradient, NSData) = ResonateShapeGenerator.shared.createRandomShape(point)

        shapeData.0.zPosition = -500
        collectionView?.add(shapeData.0)

        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: PacketType.ResonateShape, id: deviceId, data: shapeData.1)
        SocketManager.sharedManager.broadcastPacket(packet)
    }

    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let e = Schedule.shared.eventAt(indexPath)
        ArtistView.shared.event = e
        collectionView.superview?.add(ArtistView.shared)
        ArtistView.shared.reveal()
    }

    override public func scrollViewDidScroll(scrollView: UIScrollView) {
        var newOffset = scrollView.contentOffset
        if newOffset.x < 0 {
            newOffset.x += Schedule.shared.singleContentWidth
            scrollView.contentOffset = newOffset
        } else if newOffset.x > Schedule.shared.singleContentWidth {
            newOffset.x = 0
            scrollView.contentOffset = newOffset
        }

        var x = Double(scrollView.contentOffset.x / scrollView.contentSize.width)
        x *= 768.0
        x *= 2.0
        x += Double(scrollView.contentOffset.x)
        ShapeLayer.disableActions = true
        indicator.center = Point(x ,indicator.center.y)
        ShapeLayer.disableActions = false

        if scrollSource != .Local {
            return
        }

        scrollUniverseDelegate?.shouldSendScrollData()
        lastLocalInteractionTimestamp = NSDate().timeIntervalSinceReferenceDate

        interactionCeaseTimer?.invalidate()
        interactionCeaseTimer = NSTimer.scheduledTimerWithTimeInterval(interactionTimeout, target: self, selector: #selector(interactionTimedOut), userInfo: nil, repeats: false)
    }

    //MARK: RemoteInteraction

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
            let dID = SocketManager.sharedManager.deviceID - closest.deviceID
            let dx = CGFloat(dID) * CGFloat(frameCanvasWidth)
            let localOffset = CGPoint(x: dx + closest.point.x, y: 0)
            remoteScrollTo(localOffset)
        }
    }

    public func registerRemoteCease(id: Int) {
        interactionsByID[id] = nil
    }

    func remoteScrollTo(point: CGPoint) {
        if collectionView?.contentOffset == point {
            return
        }

        scrollSource = .Remote
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

}