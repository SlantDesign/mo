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
    var stars = [Element]()

    func loadData() {
        for i in 0..<AstrologicalSignProvider.shared.order.count {
            let signName = AstrologicalSignProvider.shared.order[i]

            guard let sign = AstrologicalSignProvider.shared.get(sign: signName) else {
                print("Could not find sign named: \(signName)")
                continue
            }

            let dx = Double(i) * frameCanvasWidth
            let scale = Transform.makeScale(1.25, 1.25)
            let translate = Transform.makeTranslation(Vector(x: 368.0 + dx, y: 512))

            for var p in sign.small {
                p.transform(scale)
                p.transform(translate)
                var e = Element()
                e.position = p
                e.imageName = "smallStar"
                stars.append(e)

                if e.position.x < frameCanvasWidth {
                    var duplicate = e.copy()
                    duplicate.position.x += Double(Stars.maxWidth) - frameCanvasWidth
                    stars.append(duplicate)
                }
            }

            for var p in sign.big {
                p.transform(scale)
                p.transform(translate)
                var e = Element()
                e.position = p
                e.imageName = "bigStar"
                stars.append(e)

                if e.position.x < frameCanvasWidth {
                    var duplicate = e.copy()
                    duplicate.position.x += Double(Stars.maxWidth) - frameCanvasWidth
                    stars.append(duplicate)
                }
            }
        }

        stars = stars.sorted(by: { (a, b) -> Bool in
            return a.position.x < b.position.x
        })
    }



    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let star = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as! StarCell
        star.layer.zPosition = CGFloat(indexPath.item)
        star.image = Image(stars[indexPath.item].imageName)
        return star
    }

    override init() {
        super.init()
        loadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stars.count
    }

    func element(at indexPath: IndexPath) -> Element {
        return stars[indexPath.item]
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
        for i in 0..<layoutDataSource.stars.count {
            let star = layoutDataSource.stars[i]
            if rect.intersects(CGRect(star.frame)) {
                indexes.append(IndexPath(item: i, section: 0))
            }
        }

        return indexes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutDataSource = collectionView?.dataSource as? LayoutDataSource else {
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

struct Element: Equatable {
    var position = Point()
    var imageName = "chop"

    var frame: Rect {
        var side = 60.0
        if imageName == "smallStar" {
            side = 38.0
        } else if imageName == "bigStar" {
            side = 61.0
        }
        var r = Rect(0, 0, side, side)
        r.center = position
        return r
    }

    static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.position == rhs.position ? true : false
    }

    func copy() -> Element {
        var e = Element()
        e.position = position
        e.imageName = imageName
        return e
    }
}
