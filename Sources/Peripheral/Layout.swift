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
        for i in 0..<Stars.constellationCount {
            var element = Element()

            let imageName = round(random01()) == 1 ? "chop" : "rockies"
            element.imageName = imageName

            element.position = Point(Double(i) * frameCanvasWidth + 368.0, 512.0)
            elements.append(element)

            if element.position.x < frameCanvasWidth {
                var duplicate = Element()
                duplicate.imageName = imageName
                var position = element.position
                position.x += Double(Stars.maxWidth)
                duplicate.position = position
                elements.append(duplicate)
            }

            elements = elements.sorted(by: { (a, b) -> Bool in
                return a.position.x < b.position.x
            })
        }
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let star = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as! StarCell
        star.label.text = "\(indexPath.item)"
        star.layer.zPosition = CGFloat(indexPath.item)
        star.image = Image(elements[indexPath.item].imageName)
        return star
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

        guard let layoutDataSource = self.collectionView?.dataSource as? LayoutDataSource else {
            print("could not load layoutDataSource")
            return []
        }

        var indexes = [IndexPath]()
        for i in 0..<layoutDataSource.elements.count {
            let element = layoutDataSource.elements[i]
            let frame = CGRect(x: element.position.x - 60.0, y: element.position.y - 60.0, width: 120, height: 120)
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
        attributes.frame = CGRect(x: element.position.x - 60.0, y: element.position.y - 60.0, width: 120, height: 120)
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

struct Element: Equatable {
    var position = Point()
    var imageName = "chop"
    var image: Image?

    static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.position == rhs.position ? true : false
    }
}
