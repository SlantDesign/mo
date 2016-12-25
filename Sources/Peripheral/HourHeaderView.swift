// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

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
