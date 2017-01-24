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

class LayoutDataSource: NSObject, UICollectionViewDataSource {
    static let shared = LayoutDataSource()
    var elements = [Element]()

    func loadData() {
        for _ in 0...200 {
            var element = Element()
            element.position = Point(random01() * frameCanvasWidth * 5.0, random01() * 1024.0)
            elements.append(element)
        }
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.setup()
        return cell
    }

    override init() {
        super.init()
        loadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }

    func element(at indexPath: IndexPath) -> Element {
        return elements[indexPath.item]
    }

    func indexesOfElements(in rect: CGRect) {

    }
}

class Layout: UICollectionViewLayout {
    var shapeLayers: [CAShapeLayer]!

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width:5.0 * frameCanvasWidth, height:1024.0)
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

        guard let layoutDataSource = self.collectionView?.dataSource as? LayoutDataSource else {
            print("could not load layoutDataSource")
            return []
        }

        let start = Int(floor(Double(rect.minX) / frameCanvasWidth))

        var indexes = [IndexPath]()
        for i in 0..<layoutDataSource.elements.count {
            let element = layoutDataSource.elements[i]
            let frame = CGRect(x: element.position.x, y: element.position.y, width: 120, height: 120)
            if rect.intersects(frame) {
                indexes.append(IndexPath(item: i, section: 0))
            }
        }

        return indexes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutDataSource = collectionView?.dataSource as? LayoutDataSource else {
            return nil
        }

        let element = layoutDataSource.element(at: indexPath)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: element.position.x, y: element.position.y, width: 120, height: 120)
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

struct Element: Equatable {
    var position = Point()

    static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.position == rhs.position ? true : false
    }
}
