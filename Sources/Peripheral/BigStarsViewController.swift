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
        wait(1.0) {
            guard let cv = self.collectionView else {
                print("Could not find collectionView")
                return
            }
            self.snap(cv)
        }
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

    func snap(_ scrollView: UIScrollView) {
        let index = round(scrollView.contentOffset.x / CGFloat(frameCanvasWidth))
        let point = CGPoint(x: CGFloat(index) * CGFloat(frameCanvasWidth), y: 0)
        scrollView.setContentOffset(point, animated: true)
    }

    override open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (SocketManager.sharedManager.deviceID == Stars.primaryDevice || SocketManager.sharedManager.deviceID == Stars.secondaryDevice) {
            snap(scrollView)
        }
    }

    override open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (SocketManager.sharedManager.deviceID == Stars.primaryDevice || SocketManager.sharedManager.deviceID == Stars.secondaryDevice) && !decelerate {
            snap(scrollView)
        }
    }
}
