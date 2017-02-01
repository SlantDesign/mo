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

class StarCell: UICollectionViewCell {
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
    }

    override func awakeFromNib() {
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
