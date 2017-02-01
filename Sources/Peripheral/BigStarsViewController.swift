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

open class BigStarsViewController: UICollectionViewController {
    var dx: CGFloat = 0.0
    weak var scrollDelegate: ScrollDelegate?

    override open func viewDidLoad() {
        collectionView?.register(StarCell.self, forCellWithReuseIdentifier: "StarCell")
        let id = SocketManager.sharedManager.deviceID
        dx = CGFloat(id) * CGFloat(frameCanvasWidth) - CGFloat(frameGap/2.0)
        collectionView?.contentOffset = CGPoint(x: dx, y: 0)
        collectionView?.dataSource = BigStarsDataSource.shared
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var newOffset = scrollView.contentOffset
        if newOffset.x < 0 {
            newOffset.x += (Stars.maxWidth - CGFloat(frameCanvasWidth))
        } else if newOffset.x > Stars.maxWidth - CGFloat(frameCanvasWidth) {
            newOffset.x -= (Stars.maxWidth - CGFloat(frameCanvasWidth))
        }
        scrollView.contentOffset = newOffset
        scrollDelegate?.shouldSendScrollData()
    }

    func remoteScrollTo(_ point: CGPoint) {
        if collectionView?.contentOffset == point {
            return
        }
        collectionView?.setContentOffset(point, animated: false)
    }
}