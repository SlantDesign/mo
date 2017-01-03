//
//  TimelineImage.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import C4
import Foundation
import MO

class TimelineImage: Image {
    var angle = 0.0
    var dxdy = Point()
    var dt = 0.0
    var basedt = 0.0
    var scalePeriod = 0.0
    var baseWidth = 0.0

    func update(displacement: Double) {
        scaleSize(displacement: displacement)

        var offsetdt = dt + basedt * baseWidth
        if offsetdt > 1.0 {
            offsetdt -= 1.0
        } else if offsetdt < 0.0 {
            offsetdt += 1.0
        }

        let currPos = Double(Int(offsetdt) % Int(baseWidth))
        scalePosition(period: currPos / baseWidth * 2.0 - 1.0)
    }

    func scaleSize(displacement: Double) {
        dt += displacement

        var offsetdt = fabs(dt) + basedt * baseWidth
        if offsetdt > 1.0 {
            offsetdt -= 1.0
        } else if offsetdt < 0.0 {
            offsetdt += 1.0
        }

        let currPos = Double(Int(offsetdt + baseWidth / 4.0) % Int(baseWidth))
        scalePeriod = currPos / baseWidth
        let scale = fabs(scalePeriod * 2.0 - 1.0)

        var t = Transform.makeScale(scale, scale)
        t.rotate(self.angle + M_PI)
        self.transform = t

        self.opacity = min(scale * 2.0, 1.0)
        if scale < 0.5 {
            self.zPosition = -1000
        } else {
            self.zPosition = 1000
        }
    }

    func scalePosition(period: Double) {

        var scale = period
        if period < 0 {
            scale += 1.0
        } else if period > 0 {
            scale -= 1.0
        }

        let position = (Vector(x: sin(self.angle), y: cos(self.angle)) * fabs(scale) * 200) + Vector(dxdy)
        self.center = Point(position.x, position.y)
    }
}
