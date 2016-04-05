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
    var shapeLayers: [CAShapeLayer]!

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

    var currentLayoutRect = CGRectZero

    func indexPathsOfItemsIn(rect: CGRect) -> [NSIndexPath] {
        currentLayoutRect = rect
        var paths = [NSIndexPath]()
        let startNormalized = NSTimeInterval((rect.minX % Schedule.shared.singleContentWidth) / Schedule.shared.singleContentWidth)
        let endNormalized = NSTimeInterval((rect.maxX % Schedule.shared.singleContentWidth) / Schedule.shared.singleContentWidth)

        let start = Schedule.shared.startDate.dateByAddingTimeInterval(startNormalized * Schedule.shared.totalInterval)
        let end = Schedule.shared.startDate.dateByAddingTimeInterval(endNormalized * Schedule.shared.totalInterval)

        if let dataSource = self.collectionView?.dataSource as? Schedule {
            if startNormalized > endNormalized {
                paths = dataSource.indexPathsOfEventsBetween(start, end: Schedule.shared.endDate)
                paths += dataSource.indexPathsOfEventsBetween(Schedule.shared.startDate, end: end)
            } else {
                paths = dataSource.indexPathsOfEventsBetween(start, end: end)
            }
        }
        return paths
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: UICollectionViewLayoutAttributes?
        if let dataSource = collectionView?.dataSource as? Schedule {
            let event = dataSource.eventAt(indexPath)
            attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

            var frame = dataSource.frameFor(event)
            if !CGRectIntersectsRect(frame, currentLayoutRect) {
                frame.origin.x += Schedule.shared.singleContentWidth
            }
            attributes?.frame = frame
        }
        return attributes
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}