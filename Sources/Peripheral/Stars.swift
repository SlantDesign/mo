//
//  Stars.swift
//  MO
//
//  Created by travis on 2017-01-30.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import CocoaLumberjack
import UIKit

extension PacketType {
    static let scrollStars = PacketType(rawValue: 400000)
}

public protocol ScrollDelegate: class {
    func shouldSendScrollData()
}

open class Stars: UniverseController, ScrollDelegate, GCDAsyncSocketDelegate {
    static let primaryDevice = 17
    static let constellationCount = 89
    static let maxWidth = CGFloat(constellationCount) * CGFloat(frameCanvasWidth)
    var bigStarsViewController: BigStarsViewController?
    var smallStarsViewController: SmallStarsViewController?
    var label: UILabel?

    func initializeCollectionView() {
        inititalizeSmallStars()
        inititalizeBigStars()

        if SocketManager.sharedManager.deviceID == Stars.primaryDevice {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
            var p = canvas.center
            p.y = canvas.height - 88.0
            label?.center = CGPoint(p)
            label?.textAlignment = .center
            label?.text = ""
            canvas.add(label)
        }
    }

    func inititalizeBigStars() {
        let storyboard = UIStoryboard(name: "BigStarsViewController", bundle: nil)
        bigStarsViewController = storyboard.instantiateViewController(withIdentifier: "BigStarsViewController") as? BigStarsViewController
        guard bigStarsViewController != nil else {
            print("Collection view could not be instantiated from storyboard.")
            return
        }
        bigStarsViewController?.collectionView?.dataSource = BigStarsDataSource.shared

        canvas.add(bigStarsViewController?.collectionView)
        if SocketManager.sharedManager.deviceID == Stars.primaryDevice {
            bigStarsViewController?.scrollDelegate = self
        } else {
            bigStarsViewController?.collectionView?.isUserInteractionEnabled = false
        }
    }

    func inititalizeSmallStars() {
        let storyboard = UIStoryboard(name: "SmallStarsViewController", bundle: nil)
        smallStarsViewController = storyboard.instantiateViewController(withIdentifier: "SmallStarsViewController") as? SmallStarsViewController
        guard smallStarsViewController != nil else {
            print("Collection view could not be instantiated from storyboard.")
            return
        }
        smallStarsViewController?.collectionView?.dataSource = SmallStarsDataSource.shared

        canvas.add(smallStarsViewController?.collectionView)

        smallStarsViewController?.collectionView?.isUserInteractionEnabled = false
    }

    open override func receivePacket(_ packet: Packet) {
        if packet.packetType == .scrollStars {
            let currentID = SocketManager.sharedManager.deviceID
            if currentID == Stars.primaryDevice {
                return
            }
            guard let payload = packet.payload else {
                return
            }

            let distanceFromPrimary = CGFloat(frameCanvasWidth * Double(currentID - Stars.primaryDevice))
            let offset = payload.extract(CGPoint.self, at: 0)
            let smallOffset = CGPoint(x: offset.x * SmallStarsViewController.scale, y: offset.y)

            bigStarsViewController?.collectionView?.setContentOffset(CGPoint(x: offset.x + distanceFromPrimary, y: 0), animated: false)

            //FIXME: Offset final set of stars
            //FIXME: Calibrate position of non-primary small star offsets
            smallStarsViewController?.collectionView?.setContentOffset(CGPoint(x: smallOffset.x + distanceFromPrimary * SmallStarsViewController.scale, y: 0), animated: false)
        }
    }

    public func shouldSendScrollData() {
        guard let offset = bigStarsViewController?.collectionView?.contentOffset else {
            return
        }

        if let l = label {
            let index = round(offset.x / CGFloat(frameCanvasWidth))
            l.text = AstrologicalSignProvider.shared.order[Int(index)]
        }

        if SocketManager.sharedManager.deviceID == Stars.primaryDevice {
            let smallOffset = CGPoint(x: offset.x * SmallStarsViewController.scale, y: offset.y)
            smallStarsViewController?.collectionView?.contentOffset = smallOffset

            var d = Data()
            d.append(offset)
            d.append(smallOffset)
            let p = Packet(type: .scrollStars, id: SocketManager.sharedManager.deviceID, payload: d)
            SocketManager.sharedManager.broadcastPacket(p)
        }

    }
}
