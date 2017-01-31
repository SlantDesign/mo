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

open class StarsViewController: UICollectionViewController {
    var dx: CGFloat = 0.0
    var scrollSource = ScrollSource.local
    weak var scrollDelegate: ScrollDelegate?

    override open func viewDidLoad() {
        collectionView?.register(StarCell.self, forCellWithReuseIdentifier: "StarCell")
        let id = SocketManager.sharedManager.deviceID
        dx = CGFloat(id) * CGFloat(frameCanvasWidth)
        collectionView?.contentOffset = CGPoint(x: dx, y: 0)
        collectionView?.dataSource = LayoutDataSource.shared
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var newOffset = scrollView.contentOffset
        if newOffset.x < 0 {
            newOffset.x = Stars.maxWidth - CGFloat(frameCanvasWidth)
        } else if newOffset.x > Stars.maxWidth - CGFloat(frameCanvasWidth) {
            newOffset.x = 0
        }
        scrollView.contentOffset = newOffset
    }

    func remoteScrollTo(_ point: CGPoint) {
        if collectionView?.contentOffset == point {
            return
        }
        scrollSource = .remote
        collectionView?.setContentOffset(point, animated: false)
    }
}