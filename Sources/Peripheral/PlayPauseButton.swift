//
//  PlayPauseButton.swift
//  MO
//
//  Created by travis on 2017-01-15.
//  Copyright © 2017 Slant. All rights reserved.
//

import UIKit
import C4

protocol PlayPauseButtonDelegate {
    func sendPlay()
    func sendPause()
}

class PlayPauseButton: View {
    let triangle = Triangle([Point(0, 60), Point(52, 30), Point()])
    let pauseLine = Triangle([Point(0, 60), Point(52, 30), Point()])
    var playPauseDelegate: PlayPauseButtonDelegate?
    var isPlaying = false

    override convenience init() {
        self.init(frame: Rect(0, 0, 100, 100))

        add(triangle)
        add(pauseLine)
        addTapGestureRecognizer { _, _, _ in
            self.isPlaying ? self.playPauseDelegate?.sendPause() : self.playPauseDelegate?.sendPlay()
        }

        ViewAnimation(duration: 0.0) {
            let circle = Circle(frame: self.bounds)
            circle.lineWidth = 10.0
            circle.strokeColor = white
            circle.fillColor = clear
            self.add(circle)

            self.triangle.lineWidth = 10.0
            self.triangle.strokeColor = white
            self.triangle.fillColor = clear
            self.triangle.center = Point(self.bounds.center.x + 6, self.bounds.center.y)

            self.pauseLine.lineWidth = 10.0
            self.pauseLine.strokeColor = white
            self.pauseLine.fillColor = clear
            self.pauseLine.center = Point(self.bounds.center.x + 6, self.bounds.center.y)
            self.pauseLine.strokeStart = 0.67
            self.pauseLine.hidden = true
        }.animate()

    }

    func animateToPause() {
        let anim = ViewAnimation(duration: 0.33) {
            self.triangle.strokeStart = 0.67
        }

        anim.addCompletionObserver {
            self.pauseLine.hidden = false
            ViewAnimation(duration: 0.33) {
                self.triangle.origin.x = 37
                self.pauseLine.origin.x = 63
//                self.triangle.origin.x += 7
//                self.pauseLine.origin.x += 33
                }.animate()
        }
        anim.animate()
        isPlaying = true
    }

    func animateToPlay() {
        let anim = ViewAnimation(duration: 0.33) {
            self.triangle.origin.x = 30
            self.pauseLine.origin.x = 30
//            self.triangle.origin.x -= 7
//            self.pauseLine.origin.x -= 33
        }

        anim.addCompletionObserver {
            self.pauseLine.hidden = true
            ViewAnimation(duration: 0.33) {
                self.triangle.strokeStart = 0.0
            }.animate()
        }
        anim.animate()
        isPlaying = false
    }
}
