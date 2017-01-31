//
//  LayoutDataSource.swift
//  MO
//
//  Created by travis on 2017-01-30.
//  Copyright © 2017 Slant. All rights reserved.
//

import CocoaLumberjack
import Foundation
import UIKit
import C4

class LayoutDataSource: NSObject, UICollectionViewDataSource {
    var stars = [Star]()

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
                var s = Star()
                s.position = p
                s.imageName = "smallStar"
                stars.append(s)

                if s.position.x < frameCanvasWidth {
                    var duplicate = s.copy()
                    duplicate.position.x += Double(Stars.maxWidth) - frameCanvasWidth
                    stars.append(duplicate)
                }
            }

            for var p in sign.big {
                p.transform(scale)
                p.transform(translate)
                var s = Star()
                s.position = p
                s.imageName = "bigStar"
                stars.append(s)

                if s.position.x < frameCanvasWidth {
                    var duplicate = s.copy()
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
