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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.registerClass(EventCell.self, forCellWithReuseIdentifier: "EventCell")
        collectionView?.delegate = self
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }
}