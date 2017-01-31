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
    static let primaryDevice = 18
    static let constellationCount = 28
    static let maxWidth = CGFloat(constellationCount) * CGFloat(frameCanvasWidth)
    var bigStarsViewController: BigStarsViewController?
    var smallStarsViewController: SmallStarsViewController?

    func initializeCollectionView() {
        inititalizeSmallStars()
        inititalizeBigStars()
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
        bigStarsViewController?.scrollDelegate = self

        if SocketManager.sharedManager.deviceID != Stars.primaryDevice {
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

            var offset = payload.extract(CGPoint.self, at: 0)
            let dx = CGFloat(currentID - Stars.primaryDevice) * CGFloat(frameCanvasWidth)
            offset.x += dx
            bigStarsViewController?.collectionView?.setContentOffset(offset, animated: false)
        }
    }

    public func shouldSendScrollData() {
        guard let offset = bigStarsViewController?.collectionView?.contentOffset else {
            return
        }

        smallStarsViewController?.collectionView?.contentOffset = offset

        if SocketManager.sharedManager.deviceID == Stars.primaryDevice {

            var d = Data()
            d.append(offset)
            let p = Packet(type: .scrollStars, id: SocketManager.sharedManager.deviceID, payload: d)
            SocketManager.sharedManager.broadcastPacket(p)
        }
    }
}
