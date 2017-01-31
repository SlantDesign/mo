//
//  Star.swift
//  MO
//
//  Created by travis on 2017-01-30.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import C4

struct Star: Equatable {
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

    static func == (lhs: Star, rhs: Star) -> Bool {
        return lhs.position == rhs.position ? true : false
    }

    func copy() -> Star {
        var s = Star()
        s.position = position
        s.imageName = imageName
        return s
    }
}
