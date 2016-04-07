//
//  ScheduleViewController.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import UIKit
import C4

class ScheduleViewController: UICollectionViewController {
    let indicator = Circle(center: Point(0,1014), radius: 5)
    override func viewDidLoad() {
        collectionView?.registerClass(EventCell.self, forCellWithReuseIdentifier: "EventCell")

        let headerViewNib = UINib.init(nibName: "HourHeaderView", bundle: nil)
        collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: "HourHeaderView", withReuseIdentifier: "HourHeaderView")
        collectionView?.delegate = self

        ShapeLayer.disableActions = true
        indicator.lineWidth = 0.0
        indicator.zPosition = Double(Int.max)
        collectionView?.add(indicator)
        ArtistView.shared.opacity = 0.0
        ShapeLayer.disableActions = false
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let e = Schedule.shared.eventAt(indexPath)
        ArtistView.shared.event = e
        collectionView.superview?.add(ArtistView.shared)
        ArtistView.shared.reveal()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var newOffset = scrollView.contentOffset
        if newOffset.x < 0 {
            newOffset.x += Schedule.shared.singleContentWidth
            scrollView.contentOffset = newOffset
        } else if newOffset.x > Schedule.shared.singleContentWidth {
            newOffset.x = 0
            scrollView.contentOffset = newOffset
        }

        var x = Double(scrollView.contentOffset.x / scrollView.contentSize.width)
        x *= 768.0
        x *= 2.0
        x += Double(scrollView.contentOffset.x)
        ShapeLayer.disableActions = true
        indicator.center = Point(x ,indicator.center.y)
        ShapeLayer.disableActions = false
    }
}