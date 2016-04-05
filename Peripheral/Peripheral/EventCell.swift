//
//  EventCell.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit
import Foundation

class EventCell: UICollectionViewCell {
    var shapeLayer: CellBackgroundLayer = CellBackgroundLayer() {
        didSet {
            self.layer.addSublayer(shapeLayer)
        }
    }

    var event: Event = Event()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        backgroundColor = UIColor.clearColor()
        clipsToBounds = true
        layer.addSublayer(shapeLayer)
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2.0
    }

    func animate() {
        self.shapeLayer.animate()
    }
}
