//
//  EventCell.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit

class EventCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel?
    var event: Event = Event() {
        didSet {
            titleLabel?.text = event.title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        layer.cornerRadius = 0.0
        layer.borderWidth = 1.0
        layer.backgroundColor = C4Blue.CGColor
        layer.borderColor = C4Pink.CGColor
    }
}
