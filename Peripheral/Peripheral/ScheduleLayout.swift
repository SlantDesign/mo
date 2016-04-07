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

        guard let schedule = self.collectionView?.dataSource as? Schedule else {
            return []
        }

        let startNormalized = NSTimeInterval(rect.minX / schedule.singleContentWidth)
        let startTimestamp = (startNormalized % 1.0) * schedule.totalInterval
        let startSection = Int(floor(startNormalized))

        let endNormalized = NSTimeInterval(rect.maxX / schedule.singleContentWidth)
        let endTimestamp = (endNormalized % 1.0) * schedule.totalInterval
        let endSection = Int(floor(endNormalized))

        var indexPaths = [NSIndexPath]()
        if startTimestamp > endTimestamp {
            let end = schedule.startDate.dateByAddingTimeInterval(endTimestamp)
            let beginIndexes = schedule.indexesOfEventsBetween(schedule.startDate, end: end)
            indexPaths.appendContentsOf(beginIndexes.map({ NSIndexPath(forItem: $0, inSection: endSection) }))

            let start = schedule.startDate.dateByAddingTimeInterval(startTimestamp)
            let endIndexes = schedule.indexesOfEventsBetween(start, end: schedule.endDate)
            indexPaths.appendContentsOf(endIndexes.map({ NSIndexPath(forItem: $0, inSection: startSection) }))
        } else {
            let start = schedule.startDate.dateByAddingTimeInterval(startTimestamp)
            let end = schedule.startDate.dateByAddingTimeInterval(endTimestamp)
            let indexes = schedule.indexesOfEventsBetween(start, end: end)
            indexPaths.appendContentsOf(indexes.map({ NSIndexPath(forItem: $0, inSection: startSection) }))
        }

        return indexPaths
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let schedule = collectionView?.dataSource as? Schedule else {
            return nil
        }

        let event = schedule.eventAt(indexPath)
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

        attributes.frame = schedule.frameFor(event)
        attributes.frame.origin.x += CGFloat(indexPath.section) * schedule.singleContentWidth

        return attributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let maxIndex = hourIndexFromCoordinate(Schedule.shared.singleContentWidth)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)

        if elementKind == "HourHeaderView" {
            attributes.frame = CGRect(x: hour.width * CGFloat(indexPath.item + indexPath.section * maxIndex), y: UIScreen.mainScreen().bounds.maxY-37, width: CGFloat(hour.width), height: 37)
            attributes.zIndex = -1000
        }
        return attributes
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    func indexPathsOfHourHeaderViewsInRect(rect: CGRect) -> [NSIndexPath] {
        let lowIndex = hourIndexFromCoordinate(rect.minX)
        let highIndex = hourIndexFromCoordinate(rect.maxX + hour.width)
        let maxIndex = hourIndexFromCoordinate(Schedule.shared.singleContentWidth)

        var indexPaths = [NSIndexPath]()
        for i in lowIndex..<highIndex {
            indexPaths.append(NSIndexPath(forItem: i % maxIndex, inSection: i < maxIndex ? 0 : 1))
        }

        return indexPaths
    }

    func hourIndexFromCoordinate(x: CGFloat) -> Int {
        return Int(x / hour.width)
    }
}