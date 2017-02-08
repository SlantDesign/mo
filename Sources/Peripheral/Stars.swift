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
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 44))
            var p = canvas.center
            p.y = canvas.height - 88.0
            label?.center = CGPoint(p)
            label?.textAlignment = .center
            label?.text = ""
            canvas.add(label)
            label?.textColor = UIColor.white

            guard let f = UIFont(name: "AppleSDGothicNeo-Bold", size: 32.0) else {
                print("Could not create font")
                return
            }
            label?.font = f
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

            let offset = payload.extract(CGPoint.self, at: 0)
            let smallOffset = payload.extract(CGPoint.self, at: MemoryLayout<CGPoint>.size)

            bigStarsViewController?.collectionView?.setContentOffset(CGPoint(x: offset.x, y: 0), animated: false)

            //FIXME: Offset final set of stars
            //FIXME: Calibrate position of non-primary small star offsets
            smallStarsViewController?.collectionView?.setContentOffset(CGPoint(x: smallOffset.x, y: 0), animated: false)
        }
    }

    public func shouldSendScrollData() {
        guard var offset = bigStarsViewController?.collectionView?.contentOffset else {
            return
        }

        if let l = label {
            let index = round(offset.x / CGFloat(frameCanvasWidth))

            var alpha = offset.x.truncatingRemainder(dividingBy: CGFloat(frameCanvasWidth))
            alpha /= CGFloat(frameCanvasWidth)
            if alpha < 0.5 {
                alpha = 1 - alpha
            }
            alpha -= 0.5
            alpha *= 2.0
            l.alpha = alpha
            l.text = AstrologicalSignProvider.shared.order[Int(index)]
        }

        if SocketManager.sharedManager.deviceID == Stars.primaryDevice {
            var smallOffset = CGPoint(x: offset.x * SmallStarsViewController.scale, y: offset.y)
            smallStarsViewController?.collectionView?.contentOffset = smallOffset
            let d = NSMutableData()
            d.append(&offset, length: MemoryLayout<CGPoint>.size)
            d.append(&smallOffset, length: MemoryLayout<CGPoint>.size)
            let p = Packet(type: .scrollStars, id: SocketManager.sharedManager.deviceID, payload: d as Data)
            SocketManager.sharedManager.broadcastPacket(p)
        }
    }
}
