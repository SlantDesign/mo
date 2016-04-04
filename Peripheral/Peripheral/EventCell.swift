//
//  EventCell.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit
import Foundation

class EventCell: UICollectionViewCell {
    var shapeLayer: ShapeLayer = ShapeLayer()

    var event: Event = Event() {
        didSet {
            generateLabel()
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
        backgroundColor = UIColor.clearColor()
        clipsToBounds = true
        layer.addSublayer(shapeLayer)
        layer.backgroundColor = UIColor.clearColor().CGColor
    }

    var animationOffset: CGFloat = 0.0

    func fontSizeForDay(day: String) -> Double {
        switch day {
        case "Monday":
            return 250.0
        case "Tuesday":
            return 108.0
        case "Wednesday":
            return 123.0
        case "Thursday":
            return 88.0
        case "Friday":
            return 165.0
        case "Saturday":
            return 200.0
        default:
            return 250.0
        }
    }

    //    256.0
    //    113.778
    //    128.0
    //    93.0909
    //    170.667
    //    204.8

    func generateLabel() {

        ShapeLayer.disableActions = true
        let font = Font(name: "AppleSDGothicNeo-Bold", size: fontSizeForDay(event.day))!

        //create a titleElements array
        var titleElements = [String]()
        if !event.title.isEmpty {
            titleElements.append(event.title)
        }

        let tt = TextShape(text: event.title.uppercaseString+"_", font: font)!
        if tt.width < Double(frame.width) {
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
        if originalTextPathBounds.size.width < frame.size.width {
            clipWidth = animationOffset + frame.size.width
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
        let backgroundFrame = CGRect(x: 0, y: 0, width: completeBounds.width, height: frame.height)
        let backgroundPath = CGPathCreateMutableCopy(CGPathCreateWithRect(backgroundFrame, nil))

        var transformOrigin = CGAffineTransformMakeTranslation(-originalTextPathBounds.origin.x, -originalTextPathBounds.origin.y + (backgroundFrame.height - completeBounds.height) / 2.0)

        CGPathAddPath(backgroundPath, &transformOrigin, t.path!.CGPath)

        shapeLayer.path = backgroundPath
        shapeLayer.bounds = CGPathGetBoundingBox(backgroundPath)

        shapeLayer.fillColor = colorForType(event.type)
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
        shapeLayer.removeAllAnimations()
        shapeLayer.position = CGPoint(x: shapeLayer.bounds.midX, y: shapeLayer.bounds.midY)
        let keyPath = "position"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = 30.0
        animation.beginTime = CACurrentMediaTime()
        animation.keyPath = keyPath
        animation.fromValue = NSValue(CGPoint: shapeLayer.position)
        animation.toValue = NSValue(CGPoint: CGPoint(x: shapeLayer.position.x - animationOffset, y: shapeLayer.position.y))
        animation.repeatCount = Float.infinity
        shapeLayer.addAnimation(animation, forKey:"Animate:\(keyPath)")
    }
}
