//
//  Layout.swift
//  MO
//
//  Created by travis on 2017-01-24.
//  Copyright © 2017 Slant. All rights reserved.
//

import CocoaLumberjack
import Foundation
import UIKit
import C4

class BigStarsLayout: UICollectionViewLayout {
    var shapeLayers: [CAShapeLayer]!

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width:Stars.maxWidth, height:1024.0)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        let visibleIndexPaths = indexPathsOfElements(in: rect)
        for indexPath in visibleIndexPaths {
            if let attributes = layoutAttributesForItem(at: indexPath) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    var currentLayoutRect = CGRect.zero

    func indexPathsOfElements(in rect: CGRect) -> [IndexPath] {
        currentLayoutRect = rect

        guard let layoutDataSource = self.collectionView?.dataSource as? BigStarsDataSource else {
            print("could not load layoutDataSource")
            return []
        }

        var indexes = [IndexPath]()
        for i in 0..<layoutDataSource.stars.count {
            let star = layoutDataSource.stars[i]
            if rect.intersects(CGRect(star.frame)) {
                indexes.append(IndexPath(item: i, section: 0))
            }
        }

        return indexes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutDataSource = collectionView?.dataSource as? BigStarsDataSource else {
            return nil
        }

        let star = layoutDataSource.element(at: indexPath)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(star.frame)
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
