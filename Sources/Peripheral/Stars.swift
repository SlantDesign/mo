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
    var starsViewController: StarsViewController?

    func initializeCollectionView() {
        let storyboard = UIStoryboard(name: "StarsViewController", bundle: nil)
        starsViewController = storyboard.instantiateViewController(withIdentifier: "StarsViewController") as? StarsViewController
        guard starsViewController != nil else {
            print("Collection view could not be instantiated from storyboard.")
            return
        }
        starsViewController?.collectionView?.dataSource = LayoutDataSource.shared

        canvas.add(starsViewController?.collectionView)
        starsViewController?.scrollDelegate = self
    }

    open override func receivePacket(_ packet: Packet) {
        //do stuff here
    }

    public func shouldSendScrollData() {
        //do stuff here
    }
}
