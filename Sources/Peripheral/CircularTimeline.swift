//
//  CircularTimeline.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import C4

class CircularTimeline: UniverseController {
    let img = TimelineImage("chop")!
    var t = Transform()
    var pan: UIPanGestureRecognizer?
    let angle = M_PI_4

    var images = [TimelineImage]()

    override func setup() {
        for _ in 0..<100 {
            let choice = round(random01())
            let img = TimelineImage(choice == 0 ? "chop" : "rockies")!
            img.center = canvas.center
            img.constrainsProportions = true
            img.width = 100.0
            img.angle = random01() * 2 * M_PI
            img.dxdy = canvas.center
            img.baseWidth = self.canvas.width
            img.basedt = random01()
            img.update(displacement: 0)
            images.append(img)
            canvas.add(img)
        }


        pan = canvas.addPanGestureRecognizer { _, center, translation, _, _ in
            for img in self.images {
                img.update(displacement: translation.x)
            }
            self.pan?.setTranslation(CGPoint(), in: nil)
        }
    }
}
