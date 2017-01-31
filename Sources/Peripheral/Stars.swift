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

enum ScrollSource {
    case local
    case remote
}

public protocol ScrollDelegate: class {
    func shouldSendScrollData()
}

open class Stars: UniverseController, ScrollDelegate, GCDAsyncSocketDelegate {
    static let constellationCount = 28
    static let maxWidth = CGFloat(constellationCount) * CGFloat(frameCanvasWidth)
    var bigStarsViewController: BigStarsViewController?
    var smallStarsViewController: SmallStarsViewController?

    func initializeCollectionView() {
        inititalizeSmallStars()
//        inititalizeBigStars()
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
    }

    open override func receivePacket(_ packet: Packet) {
        //do stuff here
    }

    public func shouldSendScrollData() {
        //do stuff here
    }
}
