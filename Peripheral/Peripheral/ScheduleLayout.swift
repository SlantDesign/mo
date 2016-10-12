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

    override var collectionViewContentSize : CGSize {
        return CGSize(width:Schedule.shared.totalWidth, height:1024.0)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        let visibleIndexPaths = indexPathsOfItemsIn(rect)
        for indexPath in visibleIndexPaths {
            if let attributes = layoutAttributesForItem(at: indexPath) {
                layoutAttributes.append(attributes)
            }
        }

        let hourHeaderViewIndexPaths = indexPathsOfHourHeaderViewsInRect(rect)
        for path in hourHeaderViewIndexPaths {
            if let attributes = layoutAttributesForSupplementaryView(ofKind: "HourHeaderView", at: path) {
                layoutAttributes.append(attributes)
            }
        }

        return layoutAttributes
    }

    var currentLayoutRect = CGRect.zero

    func indexPathsOfItemsIn(_ rect: CGRect) -> [IndexPath] {
        currentLayoutRect = rect

        guard let schedule = self.collectionView?.dataSource as? Schedule else {
            return []
        }

        let startNormalized = TimeInterval(rect.minX / schedule.singleContentWidth)
        let startTimestamp = (startNormalized.truncatingRemainder(dividingBy: 1.0)) * schedule.totalInterval
        let startSection = Int(floor(startNormalized))

        let endNormalized = TimeInterval(rect.maxX / schedule.singleContentWidth)
        let endTimestamp = (endNormalized.truncatingRemainder(dividingBy: 1.0)) * schedule.totalInterval
        let endSection = Int(floor(endNormalized))

        var indexPaths = [IndexPath]()
        if startTimestamp > endTimestamp {
            let end = schedule.startDate.addingTimeInterval(endTimestamp)
            let beginIndexes = schedule.indexesOfEventsBetween(schedule.startDate, end: end)
            indexPaths.append(contentsOf: beginIndexes.map({ IndexPath(item: $0, section: endSection) }))

            let start = schedule.startDate.addingTimeInterval(startTimestamp)
            let endIndexes = schedule.indexesOfEventsBetween(start, end: schedule.endDate)
            indexPaths.append(contentsOf: endIndexes.map({ IndexPath(item: $0, section: startSection) }))
        } else {
            let start = schedule.startDate.addingTimeInterval(startTimestamp)
            let end = schedule.startDate.addingTimeInterval(endTimestamp)
            let indexes = schedule.indexesOfEventsBetween(start, end: end)
            indexPaths.append(contentsOf: indexes.map({ IndexPath(item: $0, section: startSection) }))
        }

        return indexPaths
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let schedule = collectionView?.dataSource as? Schedule else {
            return nil
        }

        let event = schedule.eventAt(indexPath)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        attributes.frame = schedule.frameFor(event)
        attributes.frame.origin.x += CGFloat((indexPath as NSIndexPath).section) * schedule.singleContentWidth

        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let maxIndex = hourIndexFromCoordinate(Schedule.shared.singleContentWidth)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

        if elementKind == "HourHeaderView" {
            attributes.frame = CGRect(x: hour.width * CGFloat((indexPath as NSIndexPath).item + (indexPath as NSIndexPath).section * maxIndex), y: UIScreen.main.bounds.maxY-37, width: CGFloat(hour.width), height: 37)
            attributes.zIndex = -1000
        }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    func indexPathsOfHourHeaderViewsInRect(_ rect: CGRect) -> [IndexPath] {
        let lowIndex = hourIndexFromCoordinate(rect.minX)
        let highIndex = hourIndexFromCoordinate(rect.maxX + hour.width)
        let maxIndex = hourIndexFromCoordinate(Schedule.shared.singleContentWidth)

        var indexPaths = [IndexPath]()
        for i in lowIndex..<highIndex {
            indexPaths.append(IndexPath(item: i % maxIndex, section: i < maxIndex ? 0 : 1))
        }

        return indexPaths
    }

    func hourIndexFromCoordinate(_ x: CGFloat) -> Int {
        return Int(x / hour.width)
    }
}
