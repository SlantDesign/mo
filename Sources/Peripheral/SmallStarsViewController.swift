//
//  Parallax.swift
//  MO
//
//  Created by travis on 2017-01-24.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket
import CocoaLumberjack
import UIKit

open class SmallStarsViewController: UICollectionViewController {
    static let scale: CGFloat = 0.8
    var dx: CGFloat = 0.0
    weak var scrollDelegate: ScrollDelegate?

    override open func viewDidLoad() {
        collectionView?.register(StarCell.self, forCellWithReuseIdentifier: "StarCell")
        let id = SocketManager.sharedManager.deviceID
        dx = CGFloat(id) * CGFloat(frameCanvasWidth) - CGFloat(frameGap/2.0)
        collectionView?.contentOffset = CGPoint(x: dx * SmallStarsViewController.scale, y: 0)
        collectionView?.dataSource = SmallStarsDataSource.shared
    }

    func remoteScrollTo(_ point: CGPoint) {
        if collectionView?.contentOffset == point {
            return
        }
        collectionView?.setContentOffset(point, animated: false)
    }
}
