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
    static let scrollStars2 = PacketType(rawValue: 400001)
}

public protocol ScrollDelegate: class {
    func shouldSendScrollData()
}

open class Stars: UniverseController, ScrollDelegate, GCDAsyncSocketDelegate {
    static let primaryDevice = 17
    static let secondaryDevice = 19
    static let constellationCount = 89
    static let maxWidth = CGFloat(constellationCount) * CGFloat(frameCanvasWidth)
    var big1: BigStarsViewController?
    var big2: BigStarsViewController?
    var small1: SmallStarsViewController?
    var small2: SmallStarsViewController?
    var label: UILabel?

    open override func setup() {
        super.setup()
        canvas.backgroundColor = black
        let background = View(frame: Rect(dx-256, 0, 1024, 1024))
        for x in 0...3 {
            for y in 0...3 {
                guard let image = Image("background") else {
                    print("Could not create background image")
                    return
                }
                let origin = Point(Double(x) * 256.0, Double(y) * 256.0)
                image.origin = origin
                background.add(image)
            }
        }

        canvas.add(background)

        let anim = ViewAnimation(duration: 60.0) {
            background.origin = Point(self.dx, 0)
        }
        anim.repeats = true
        anim.curve = .Linear
        anim.animate()
    }

    func initializeCollectionViews() {
        if SocketManager.sharedManager.deviceID != Stars.primaryDevice &&
            SocketManager.sharedManager.deviceID != Stars.secondaryDevice {
            small2 = inititalizeSmallStars()
            small2?.collectionView?.alpha = 0.5
            big2 = inititalizeBigStars()
            big2?.collectionView?.alpha = 0.5
            canvas.add(small2?.collectionView)
            canvas.add(big2?.collectionView)
            small1 = inititalizeSmallStars()
            small1?.collectionView?.alpha = 0.5
            big1 = inititalizeBigStars()
            big1?.collectionView?.alpha = 0.5
            canvas.add(small1?.collectionView)
            canvas.add(big1?.collectionView)
        } else {
            small1 = inititalizeSmallStars()
            big1 = inititalizeBigStars()
            canvas.add(small1?.collectionView)
            canvas.add(big1?.collectionView)
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 44))
            var p = Point(dx + canvas.center.x, canvas.height - 88.0)
            label?.center = CGPoint(p)
            label?.textAlignment = .center
            label?.text = ""
            canvas.add(label)
            label?.textColor = UIColor.white

            guard let f = UIFont(name: "Inconsolata", size: 32.0) else {
                print("Could not create font")
                return
            }
            label?.font = f
        }
    }

    func inititalizeBigStars() -> BigStarsViewController? {
        let storyboard = UIStoryboard(name: "BigStarsViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BigStarsViewController") as? BigStarsViewController else {
            print("Collection view could not be instantiated from storyboard.")
            return nil
        }
        vc.collectionView?.dataSource = BigStarsDataSource.shared
        if SocketManager.sharedManager.deviceID == Stars.primaryDevice ||
            SocketManager.sharedManager.deviceID == Stars.secondaryDevice {
            vc.scrollDelegate = self
        } else {
            vc.collectionView?.isUserInteractionEnabled = false
        }
        vc.collectionView?.frame.origin = CGPoint(x: CGFloat(dx), y: 0)
        return vc
    }

    func inititalizeSmallStars() -> SmallStarsViewController? {
        let storyboard = UIStoryboard(name: "SmallStarsViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SmallStarsViewController") as? SmallStarsViewController else {
            print("Collection view could not be instantiated from storyboard.")
            return nil
        }
        vc.collectionView?.frame.origin = CGPoint(x: CGFloat(dx), y: 0)
        vc.collectionView?.dataSource = SmallStarsDataSource.shared
        vc.collectionView?.isUserInteractionEnabled = false
        return vc
    }

    open override func receivePacket(_ packet: Packet) {
        if packet.packetType == .scrollStars || packet.packetType == .scrollStars2 {
            let currentID = SocketManager.sharedManager.deviceID
            if currentID == Stars.primaryDevice ||
                currentID == Stars.secondaryDevice {
                return
            }
            guard let payload = packet.payload else {
                return
            }

            let offset = payload.extract(CGPoint.self, at: 0)
            let smallOffset = payload.extract(CGPoint.self, at: MemoryLayout<CGPoint>.size)

            let bigSmall = determineBigOrSmall(packetType: packet.packetType)

            guard let big = bigSmall.0 else {
                return
            }
            big.collectionView?.setContentOffset(CGPoint(x: offset.x, y: 0), animated: false)

            //FIXME: Offset final set of stars
            //FIXME: Calibrate position of non-primary small star offsets
            guard let small = bigSmall.1 else {
                return
            }
            small.collectionView?.setContentOffset(CGPoint(x: smallOffset.x, y: 0), animated: false)
        }
    }

    func determineBigOrSmall(packetType: PacketType) -> (BigStarsViewController?, SmallStarsViewController?) {
        if packetType == .scrollStars {
            return (big1, small1)
        } else if packetType == .scrollStars2 {
            return (big2, small2)
        }
        return (nil, nil)
    }

    public func shouldSendScrollData() {
        guard var offset = big1?.collectionView?.contentOffset else {
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

        if SocketManager.sharedManager.deviceID == Stars.primaryDevice ||
            SocketManager.sharedManager.deviceID == Stars.secondaryDevice {
            var smallOffset = CGPoint(x: offset.x * SmallStarsViewController.scale, y: offset.y)
            small1?.collectionView?.contentOffset = smallOffset
            let d = NSMutableData()
            d.append(&offset, length: MemoryLayout<CGPoint>.size)
            d.append(&smallOffset, length: MemoryLayout<CGPoint>.size)

            var packetType = PacketType.scrollStars
            if SocketManager.sharedManager.deviceID == Stars.secondaryDevice {
                packetType = .scrollStars2
            }

            let p = Packet(type: packetType, id: SocketManager.sharedManager.deviceID, payload: d as Data)
            SocketManager.sharedManager.broadcastPacket(p)
        }
    }
}
