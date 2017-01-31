//
//  StarCell.swift
//  MO
//
//  Created by travis on 2017-01-30.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import UIKit
import C4

//You need to create a customizable / repeatable object that represents
//the kinds of elements you want to see in your collection view
class StarCell: UICollectionViewCell {
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    var image: Image? {
        willSet {
            image?.removeFromSuperview()
        } didSet {
            add(image)
            sendToBack(image)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        add(label)
    }

    override func awakeFromNib() {
        clipsToBounds = true
        add(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
