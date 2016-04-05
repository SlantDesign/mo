//
//  ScheduleViewController.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import UIKit

class ScheduleViewController: UICollectionViewController {
    override func viewDidLoad() {
        collectionView?.registerClass(EventCell.self, forCellWithReuseIdentifier: "EventCell")

        let headerViewNib = UINib.init(nibName: "HourHeaderView", bundle: nil)
        collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: "HourHeaderView", withReuseIdentifier: "HourHeaderView")
        collectionView?.delegate = self
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
    }
}