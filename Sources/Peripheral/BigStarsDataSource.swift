//
//  BigStarsDataSource.swift
//  MO
//
//  Created by travis on 2017-01-30.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import UIKit
import C4

class BigStarsDataSource: NSObject, UICollectionViewDataSource {
    static let shared = BigStarsDataSource()
    var elements = [Star]()
    var stars = [Star]()

    func loadData() {
        for i in 0..<AstrologicalSignProvider.shared.order.count {
            let signName = AstrologicalSignProvider.shared.order[i]

            guard let sign = AstrologicalSignProvider.shared.get(sign: signName) else {
                print("Could not find sign named: \(signName)")
                continue
            }

            let dx = 368.0 + Double(i) * frameCanvasWidth
            let scale = Transform.makeScale(1.25, 1.25)
            let translate = Transform.makeTranslation(Vector(x: dx, y: 512))

            for var p in sign.big {
                p.transform(scale)
                p.transform(translate)
                var star = Star()
                star.position = p
                star.imageName = "bigStar"
                stars.append(star)

                if star.position.x < frameCanvasWidth {
                    var duplicate = star.copy()
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
    
    func element(at indexPath: IndexPath) -> Star {
        return stars[indexPath.item]
    }
}
