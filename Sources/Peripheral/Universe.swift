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
import SpriteKit

extension PacketType {
    static let scrollStars = PacketType(rawValue: 400000)
    static let scrollStars2 = PacketType(rawValue: 400001)
}

public protocol ScrollDelegate: class {
    func shouldSendScrollData()
}

open class Universe: UniverseController, ScrollDelegate, GCDAsyncSocketDelegate {
    var currentScene: UniverseScene?

    let sceneView = SKView()

    open override func setup() {
        super.setup()
        createBackground()
        createSceneView()
        loadScene()
    }

    func createSceneView() {
        sceneView.frame = CGRect(x: CGFloat(dx), y: 0.0, width: view.frame.width, height: view.frame.height)
        sceneView.ignoresSiblingOrder = false
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        sceneView.allowsTransparency = true
        sceneView.backgroundColor = .clear
    }

    func loadScene() {
        switch SocketManager.sharedManager.deviceID {
        case Sun.primaryDevice - 1, Sun.primaryDevice, Sun.primaryDevice + 1:
            currentScene = Sun(size: sceneView.frame.size)
        default:
            return
        }

        canvas.add(sceneView)
        currentScene?.scaleMode = .aspectFill
        sceneView.presentScene(currentScene)
    }

    func createBackground() {
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

    //MARK: Sun
    func handleSun(_ packet: Packet) {
        //If the current scene is not a Sun, do nothing
        guard let scene = currentScene as? Sun else {
            print("Current Scene is not Sun")
            return
        }

        //If there is no data, do nothing
        guard let data = packet.payload else {
            print("Could not extract payload data")
            return
        }

        //By now, the current scene is a sun, and there is data
        //Unpack all the variables
        var index = 0
        let id = data.extract(Int.self, at: index)
        index += MemoryLayout<Int>.size
        var point = data.extract(CGPoint.self, at: index)
        index += MemoryLayout<CGPoint>.size
        let effectNameIndex = data.extract(Int.self, at: index)
        index += MemoryLayout<Int>.size
        let angle = data.extract(Int.self, at: index)

        //if the sending device is the current device
        if SocketManager.sharedManager.deviceID == packet.id {
            //create the desired effect in place
            scene.createEffect(nameIndex: effectNameIndex, at: point, angle: angle)
        } else if SocketManager.sharedManager.deviceID == id {
            //otherwise, this device is a neighbour, so we offset the position for the effect
            let dx = CGFloat(packet.id - SocketManager.sharedManager.deviceID) * CGFloat(frameCanvasWidth)
            point.x += dx
            scene.createEffect(nameIndex: effectNameIndex, at: point, angle: angle)
        }
    }

    //MARK: Stars
    var big1: BigStarsViewController?
    var big2: BigStarsViewController?
    var small1: SmallStarsViewController?
    var small2: SmallStarsViewController?
    var label: UILabel?

    func initializeCollectionViews() {
        if SocketManager.sharedManager.deviceID != Stars.primaryDevice &&
            SocketManager.sharedManager.deviceID != Stars.secondaryDevice {
            small2 = inititalizeSmallStars()
            small2?.collectionView?.alpha = 0.25
            big2 = inititalizeBigStars()
            big2?.collectionView?.alpha = 0.25
            canvas.add(small2?.collectionView)
            canvas.add(big2?.collectionView)
            small1 = inititalizeSmallStars()
            small1?.collectionView?.alpha = 0.25
            big1 = inititalizeBigStars()
            big1?.collectionView?.alpha = 0.25
            canvas.add(small1?.collectionView)
            canvas.add(big1?.collectionView)
        } else {
            small1 = inititalizeSmallStars()
            big1 = inititalizeBigStars()
            canvas.add(small1?.collectionView)
            canvas.add(big1?.collectionView)
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 44))
            let p = Point(dx + canvas.center.x, canvas.height - 88.0)
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
        switch packet.packetType {
        case PacketType.sun:
            handleSun(packet)
        case PacketType.scrollStars, PacketType.scrollStars2:
            handleScrollingStars(packet)
        default:
            break
        }
    }

    func updateLabelOpacity(_ offset: CGPoint) {
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
    }

    func handleScrollingStars(_ packet: Packet) {
        //if the current device is either of the two observatories, do nothing
        if SocketManager.sharedManager.deviceID == Stars.primaryDevice ||
            SocketManager.sharedManager.deviceID == Stars.secondaryDevice {
            return
        }

        //if there is no data, do nothing
        guard let payload = packet.payload else {
            return
        }

        //grab the big stars offset
        let offset = payload.extract(CGPoint.self, at: 0)

        //grab the small stars offset
        let smallOffset = payload.extract(CGPoint.self, at: MemoryLayout<CGPoint>.size)

        //extract the big / small stars for the current packet type (e.g. from device 1, or 2)
        let bigSmall = determineBigOrSmall(packetType: packet.packetType)

        //if there is no big stars controller, do nothing
        guard let big = bigSmall.0 else {
            print("Could not extract big")
            return
        }
        big.collectionView?.setContentOffset(CGPoint(x: offset.x, y: 0), animated: false)

        //if there is no small stars controller, do nothing
        guard let small = bigSmall.1 else {
            print("Could not extract big")
            return
        }
        small.collectionView?.setContentOffset(CGPoint(x: smallOffset.x, y: 0), animated: false)
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
        guard let offset = big1?.collectionView?.contentOffset else {
            return
        }

        updateLabelOpacity(offset)

        if SocketManager.sharedManager.deviceID == Stars.primaryDevice ||
            SocketManager.sharedManager.deviceID == Stars.secondaryDevice {
            sendScrollingStarsData(offset)
        }
    }

    func sendScrollingStarsData(_ point: CGPoint) {
        var offset = point
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
