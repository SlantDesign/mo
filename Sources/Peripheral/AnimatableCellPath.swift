// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import Foundation
import UIKit
import C4

class AnimatableCellPath {
    var path: CGPath!
    var fillColor: CGColor!
    var animationOffset: CGFloat = 0.0
    var visibleFrame = CGRect.zero
    var event: Event!

    init(frame f: CGRect, event e: Event, color c: CGColor) {
        visibleFrame = f
        event = e
        fillColor = c
        generatePath()
    }

    func generatePath() {
        let font = Font(name: "UniversLTStd-LightUltraCn", size: Double(visibleFrame.size.height))!

        //create a titleElements array
        var titleElements = [String]()
        if !event.title.isEmpty {
            titleElements.append(event.title)
        }

        let tt = TextShape(text: event.title.uppercased()+"–", font: font)!
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

        guard title != "" else {
            print("Could not create a title")
            return
        }

        let t = TextShape(text: (title + "–").uppercased(), font: font)!

        let originalTextPath = t.path!.CGPath
        let originalTextPathBounds = originalTextPath.boundingBox

        //finds gap between last character and first character of repeating elements
        let suffix = "\(title[title.characters.index(before: title.endIndex)])"
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
            t.text = title.uppercased()
            i += 1
            if i >= characters.count {
                i = 0
            }
        }

        let completeBounds = (t.path!.CGPath).boundingBox
        let backgroundFrame = CGRect(x: 0, y: 0, width: completeBounds.width, height: visibleFrame.height)
        let backgroundPath = CGPath(rect: backgroundFrame, transform: nil).mutableCopy()

        let transformOrigin = CGAffineTransform(translationX: -originalTextPathBounds.origin.x, y: -originalTextPathBounds.origin.y + (backgroundFrame.height - completeBounds.height) / 2.0)

        backgroundPath?.addPath(t.path!.CGPath, transform: transformOrigin)

        path = backgroundPath
    }
}
