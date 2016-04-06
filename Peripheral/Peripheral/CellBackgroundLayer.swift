//
//  CellBackgroundLayer.swift
//  Peripheral
//
//  Created by travis on 2016-04-04.
//  Copyright © 2016 C4. All rights reserved.
//

import UIKit
import C4

class CellBackgroundLayer: ShapeLayer {
    var animationOffset: CGFloat = 0.0
    var visibleFrame = CGRectZero

    convenience init(event: Event, visibleFrame: CGRect) {
        self.init()
        self.visibleFrame = visibleFrame
        self.backgroundColor = UIColor.clearColor().CGColor
        self.generateLabel(event)
    }

    func generateLabel(event: Event) {
        let font = Font(name: "AppleSDGothicNeo-Bold", size: Double(visibleFrame.size.height))!

        //create a titleElements array
        var titleElements = [String]()
        if !event.title.isEmpty {
            titleElements.append(event.title)
        }

        let tt = TextShape(text: event.title.uppercaseString+"_", font: font)!
        if tt.width < Double(visibleFrame.width) {
            for artist in event.artists {
                titleElements.append(artist)
            }
        }

        var title = ""
        for element in titleElements {
            title += element
            if element != titleElements.last {
                title += "–"
            }
        }

        if title.isEmpty {
            print("")
        }

        let t = TextShape(text: (title + "–").uppercaseString, font: font)!

        let originalTextPath = t.path!.CGPath
        let originalTextPathBounds = CGPathGetBoundingBox(originalTextPath)

        //finds gap between last character and first character of repeating elements
        let suffix = "\(title[title.endIndex.predecessor()])"
        let first = "\(title[title.startIndex])"

        let t1 = TextShape(text: suffix, font: font)!
        let t2 = TextShape(text: first, font: font)!
        let t3 = TextShape(text: suffix+first, font: font)!

        let diff = t3.width - t2.width - t1.width

        //creates animation offset, including gap
        animationOffset = originalTextPathBounds.size.width + CGFloat(diff)
        var clipWidth = animationOffset * 2.0
        if originalTextPathBounds.size.width < visibleFrame.size.width {
            clipWidth = animationOffset + visibleFrame.size.width
        }

        var i = 0
        let characters = Array(title.characters)
        while t.width < Double(clipWidth) {
            if i == 0 {
                title += "–"
            }
            title += "\(characters[i])"
            t.text = title.uppercaseString
            i += 1
            if i >= characters.count {
                i = 0
            }
        }

        let completeBounds = CGPathGetBoundingBox(t.path!.CGPath)
        let backgroundFrame = CGRect(x: 0, y: 0, width: completeBounds.width, height: visibleFrame.height)
        let backgroundPath = CGPathCreateMutableCopy(CGPathCreateWithRect(backgroundFrame, nil))

        var transformOrigin = CGAffineTransformMakeTranslation(-originalTextPathBounds.origin.x, -originalTextPathBounds.origin.y + (backgroundFrame.height - completeBounds.height) / 2.0)

        CGPathAddPath(backgroundPath, &transformOrigin, t.path!.CGPath)

        path = backgroundPath
        bounds = CGPathGetBoundingBox(backgroundPath)

        fillColor = colorForType(event.type)
    }

    func colorForType(type: String) -> CGColor {
        switch type {
        case "IntensiveWorkshop":
            return UIColor.blueColor().CGColor
        case "Workshop":
            return UIColor.redColor().CGColor
        case "Screening":
            return UIColor.greenColor().CGColor
        case "Lecture":
            return UIColor.darkGrayColor().CGColor
        case "Performance":
            return UIColor.purpleColor().CGColor
        case "QA":
            return UIColor.magentaColor().CGColor
        case "Panel":
            return UIColor.orangeColor().CGColor
        case "Venue":
            return UIColor.yellowColor().CGColor
        case "OverNight":
            return UIColor.whiteColor().CGColor
        default:
            return UIColor.lightGrayColor().CGColor
        }
    }

    func animate() {
        removeAllAnimations()
        position = CGPoint(x: bounds.midX, y: bounds.midY)
        let keyPath = "position"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = 30.0
        animation.beginTime = CACurrentMediaTime()
        animation.keyPath = keyPath
        animation.fromValue = NSValue(CGPoint: position)
        animation.toValue = NSValue(CGPoint: CGPoint(x: position.x - animationOffset, y: position.y))
        animation.repeatCount = Float.infinity
        addAnimation(animation, forKey:"Animate:\(keyPath)")
    }
}