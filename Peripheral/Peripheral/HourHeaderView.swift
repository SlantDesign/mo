//
//  HourLabel.swift
//  Peripheral
//
//  Created by travis on 2016-04-05.
//  Copyright © 2016 C4. All rights reserved.
//

import UIKit
import C4

class HourHeaderView: UICollectionReusableView {
    @IBOutlet var label: UILabel?

    override func awakeFromNib() {
        let line = Line(begin: Point(0,Double(self.frame.size.height)), end: Point(0,Double(self.frame.size.height-1024.0)))
        line.strokeColor = white
        line.lineWidth = 0.25
        clipsToBounds = false
        layer.addSublayer(line.shapeLayer)
    }
}
