//
//  ScheduleLayout.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import UIKit

class ScheduleLayout: UICollectionViewLayout {

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func collectionViewContentSize() -> CGSize {
        return CGSize(width:Schedule.shared.totalWidth, height:1024.0)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        let visibleIndexPaths = indexPathsOfItemsIn(rect)
        for indexPath in visibleIndexPaths {
            if let attributes = layoutAttributesForItemAtIndexPath(indexPath) {
                layoutAttributes.append(attributes)
            }
        }

        return layoutAttributes
    }

    func indexPathsOfItemsIn(rect: CGRect) -> [NSIndexPath] {
        if rect.origin.x < 0 {
            print(rect.origin.x)
        }
        var paths = [NSIndexPath]()
        let start = Schedule.shared.startDate.dateByAddingTimeInterval(NSTimeInterval(rect.minX / Schedule.shared.totalWidth) * Schedule.shared.totalInterval)
        let end = Schedule.shared.startDate.dateByAddingTimeInterval(NSTimeInterval(rect.maxX / Schedule.shared.totalWidth) * Schedule.shared.totalInterval)

        if let dataSource = self.collectionView?.dataSource as? Schedule {
            paths = dataSource.indexPathsOfEventsBetween(start, end: end)
        }
        return paths
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: UICollectionViewLayoutAttributes?
        if let dataSource = collectionView?.dataSource as? Schedule {
            let event = dataSource.eventAt(indexPath)
            attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes?.frame = dataSource.frameFor(event)
        }
        return attributes
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}