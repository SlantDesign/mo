//
//  SlidingScrollview.swift
//  M-O
//
//  Created by travis on 2016-03-11.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit
import CocoaLumberjackSwift

public class Spiral : UniverseController {
    let scrollViewRotation = -M_PI/32
    private var userDidScrollContext = true
    private var userDidNotScrollContext = false
    private var currentContext = true

    let container = View()
    let scrollview = InfiniteScrollView()
    let interaction = InfiniteScrollView()
    var primaryCenter = Point()
    let pageCount = 60
    var colors: [Color]!
    var shouldReportContentOffset: Bool = true
    var spiralUniverseDelegate: SpiralUniverseDelegate?

    public override func setup() {

        container.frame = canvas.frame
        scrollview.frame = view.frame
        scrollview.userInteractionEnabled = false
        container.add(scrollview)
        canvas.add(container)

        container.rotation = scrollViewRotation
        container.masksToBounds = false
        container.center.x -= 997
        primaryCenter = container.center
        scrollview.clipsToBounds = false

        colors = generateColors(steps: pageCount)

        for i in 0..<pageCount {
            let v = View(frame: canvas.frame)
            v.backgroundColor = colors[i]


            let label = TextShape(text: "\(i)")
            label?.fillColor = white
            label?.center = v.center
            v.add(label)

            if i == 0 {
                let copy = View(copyView: v)
                copy.origin = Point(Double(pageCount)*v.width, 0)

                let label = TextShape(text: "\(i)")
                label?.fillColor = white
                label?.center = v.center
                copy.add(label)

                scrollview.add(copy)
            }

            if i == pageCount - 1 {
                let copy = View(copyView: v)
                copy.origin = Point(-v.width, 0)

                let label = TextShape(text: "\(i)")
                label?.fillColor = white
                label?.center = v.center
                copy.add(label)

                scrollview.add(copy)
            }

            v.origin = Point(canvas.width * Double(i), 0)

            scrollview.add(v)
        }

        scrollview.contentSize = CGSize(width: scrollview.frame.width * CGFloat(pageCount + 1), height: 1)

        interaction.frame = CGRect(inset(canvas.frame, dx: -canvas.width * 0.22, dy: -canvas.height * 0.11))
        interaction.layer.borderColor = UIColor.redColor().CGColor
        interaction.layer.borderWidth = 1.0
        interaction.contentSize = CGSize(width: interaction.frame.width * CGFloat(pageCount + 1), height: 1)

        interaction.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)

        interaction.transform = CGAffineTransformMakeRotation(CGFloat(scrollViewRotation))

        var p = canvas.center
        p.x += dx
        interaction.center = CGPoint(p)
        canvas.add(interaction)

        if let grs = interaction.gestureRecognizers {
            for g in grs {
                g.addTarget(self, action: "registerUserInteraction:")
            }
        }
    }

    public var shouldReportScroll: Bool {
        return currentContext
    }

    public func registerUserInteraction(gestureRecognizer: UIGestureRecognizer) {
        currentContext = userDidScrollContext
    }

    public func registerRemoteUserInteraction(point: CGPoint) {
        currentContext = userDidNotScrollContext
        if scrollview.contentOffset != point {
            scrollview.contentOffset = point
            let normalOffset = (scrollview.contentOffset.x / scrollview.contentSize.width)
            let targetOffset = normalOffset * interaction.contentSize.width
            interaction.contentOffset = CGPoint(x: targetOffset,y: 0)
            let y = primaryCenter.y + map(Double(normalOffset), min: 0, max: 1, toMin: -120, toMax: 120)
            container.center.y = y
        }
    }

    func generateColors(from c1: Color = C4Pink, to c2: Color = C4Blue, steps: Int) -> [Color] {
        let vP = Vector(x: c1.red, y: c1.green, z: c1.blue)
        let vB = Vector(x: c2.red, y: c2.green, z: c2.blue)

        let dBP = vB - vP

        let step = dBP / Double(steps)

        var vC = Vector(x: vP.x, y: vP.y, z: vP.z)
        var colorSteps = [Color]()
        for _ in 0..<steps {
            let c = Color(red: vC.x, green: vC.y, blue: vC.z, alpha: 1.0)
            colorSteps.append(c)
            vC += step
        }
        return colorSteps
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if currentContext {
            let normalOffset = (interaction.contentOffset.x / interaction.contentSize.width)
            let targetOffset = normalOffset * scrollview.contentSize.width
            if scrollview.contentOffset.x != targetOffset {
                scrollview.contentOffset = CGPoint(x: targetOffset,y: 0)
                let y = primaryCenter.y + map(Double(normalOffset), min: 0, max: 1, toMin: -120, toMax: 120)
                container.center.y = y
                spiralUniverseDelegate?.shouldSendScrollData()
            }
        }
    }
}