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

        let hourHeaderViewIndexPaths = indexPathsOfHourHeaderViewsInRect(rect)
        for path in hourHeaderViewIndexPaths {
            if let attributes = layoutAttributesForSupplementaryViewOfKind("HourHeaderView", atIndexPath: path) {
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

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)

        if elementKind == "HourHeaderView" {
            attributes.frame = CGRect(x: CGFloat(hour.width) * CGFloat(indexPath.item), y: UIScreen.mainScreen().bounds.maxY-37, width: CGFloat(hour.width), height: 37)
            attributes.zIndex = -1000
        }
        return attributes
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    func indexPathsOfHourHeaderViewsInRect(rect: CGRect) -> [NSIndexPath] {

        let minIndex = hourIndexFromCoordinate(Double(rect.minX))
        let maxIndex = hourIndexFromCoordinate(Double(rect.maxX) + hour.width)

        var indexPaths = Set<NSIndexPath>()
        for i in minIndex..<maxIndex {
            indexPaths.insert(NSIndexPath(forItem: i, inSection: 0))
        }

        var paths = [NSIndexPath](indexPaths)
        paths.sortInPlace {
            $0.item < $1.item
        }
        return paths
    }

    func hourIndexFromCoordinate(x: Double) -> Int {
        let hourIndex = max(0.0, x / hour.width)
        return Int(hourIndex)
    }
}