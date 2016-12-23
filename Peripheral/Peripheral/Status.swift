//
//  Status.swift
//  Peripheral
//
//  Created by travis on 2016-04-07.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import UIKit
import C4

class Status: UniverseController {
    var player: AudioPlayer!
    var timer: C4.Timer?

    var maxPaths = (Path(), Path())
    var avgPaths = (Path(), Path())
    var maxShapes = (Shape(), Shape())
    var avgShapes = (Shape(), Shape())
    var maxPeak = (32.5689125061035, 33.0002746582031)
    var avgPeak = (39.2663803100586, 39.722785949707)
    var Θ = 0.0

    override func setup() {
        canvas.bounds.origin.x = 0.0
        canvas.backgroundColor = Color(red: 0.12, green: 0.14, blue: 0.14, alpha: 1.0)
        resetPaths()
        setupShapes()
        setupPlayer()
        setupTimer()
        setupLogo()
    }

    func setupLogo() {
        let logo = Image("LFLogo")
        logo?.anchorPoint = Point(0.337, 0.468)
        logo?.center = canvas.center
        canvas.add(logo)
    }

    func setupPlayer() {
        player = AudioPlayer("BlackVelvet.mp3")
        player?.meteringEnabled = true
        player?.loops = true
        player?.play()
    }

    func normalize(_ val: Double, max: Double) -> Double {
        var normMax = abs(val)
        normMax /= max
        return normMax * 100.0 + 100.0
    }

    func setupTimer() {
        timer = C4.Timer(interval: 1.0/60.0) {
            ShapeLayer.disableActions = true
            self.player.updateMeters()
            self.generateNextPoints()
            self.updateShapes()
            ShapeLayer.disableActions = false
        }

        timer?.start()
    }

    func generatePoint(_ val: Double) -> Point {
        return Point(val * cos(Θ), val * sin(Θ))
    }

    func generateNextPoints() {
        let max0 = normalize(player.peakPower(0), max: maxPeak.0)
        maxPaths.0.addLineToPoint(generatePoint(max0))

        let max1 = normalize(player.peakPower(1), max: maxPeak.1)
        maxPaths.1.addLineToPoint(generatePoint(max1))

        let avg0 = normalize(player.averagePower(0), max: avgPeak.0)
        avgPaths.0.addLineToPoint(generatePoint(avg0))

        let avg1 = normalize(player.averagePower(1), max: avgPeak.1)
        avgPaths.1.addLineToPoint(generatePoint(avg1))

        Θ += M_PI / 180.0

        if Θ >= 2 * M_PI {
            Θ = 0.0
            resetPaths()
        }
    }

    func updateShapes() {
        maxShapes.0.path = maxPaths.0
        maxShapes.0.center = canvas.center
        maxShapes.1.path = maxPaths.1
        maxShapes.1.center = canvas.center
        avgShapes.0.path = avgPaths.0
        avgShapes.0.center = canvas.center
        avgShapes.1.path = avgPaths.1
        avgShapes.1.center = canvas.center
    }

    func setupShapes() {
        maxShapes = (Shape(), Shape())
        maxShapes.0.path = maxPaths.0
        maxShapes.1.path = maxPaths.1
        avgShapes = (Shape(), Shape())
        avgShapes.0.path = avgPaths.0
        avgShapes.1.path = avgPaths.1

        styleShape(maxShapes.0)
        styleShape(maxShapes.1)
        styleShape(avgShapes.0)
        styleShape(avgShapes.1)

        canvas.add(maxShapes.0)
        canvas.add(maxShapes.1)
        canvas.add(avgShapes.0)
        canvas.add(avgShapes.1)

        maxShapes.1.transform.rotate(M_PI)
        avgShapes.0.transform.rotate(M_PI_2)
        avgShapes.1.transform.rotate(M_PI_2 * 3)
    }

    func styleShape(_ shape: Shape) {
        shape.lineWidth = 0.25
        shape.fillColor = clear
        shape.strokeColor = white
    }
    
    func resetPaths() {
        maxPaths = (Path(), Path())
        avgPaths = (Path(), Path())
    }

    override func unload() {
        player.stop()
        for i in 0..<canvas.view.subviews.count {
            let view = canvas.view.subviews[i]
            let fade = ViewAnimation(duration: 0.25) {
                view.alpha = 0.0
            }
            fade.delay = Double(i) * 0.1
            fade.addCompletionObserver {
                view.removeFromSuperview()
            }
            fade.animate()
        }
    }
}
