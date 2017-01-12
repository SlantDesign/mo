//
//  NoskPoint.swift
//  MO
//
//  Created by travis on 2017-01-11.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import C4

class NoskPoint: View {
    var imageContainer = View(frame: Rect(0,0,44,44))

    public convenience override init() {
        self.init(frame: Rect(0, 0, 220, 44))

        let f = Rect(CGRect(frame).insetBy(dx: -4, dy: -4))
        let r = Rectangle(frame: f)
        r.lineWidth = 1.0
        r.fillColor = C4Grey
        add(r)

        add(imageContainer)
        imageContainer.masksToBounds = true
    }

    var title: TextShape?
    var writeup: TextShape?

    var tag = 0 {
        didSet {
            if let t = title {
                remove(t)
            }

            let font = Font(name: "Helvetica-Bold", size: 18)!
            title = TextShape(text: "ELEMENT \(tag)", font: font)!
            title?.origin = Point(50.0, 0.0)
            title?.lineWidth = 0.0
            title?.fillColor = C4Purple
            add(title)

            writeup = TextShape(text: "This is a description of element \(tag).", font: font.font(10))
            writeup?.origin = Point(50.0, title!.height + 6)
            writeup?.lineWidth = 0.0
            writeup?.fillColor = C4Purple
            add(writeup)

            for v in imageContainer.view.subviews {
                v.removeFromSuperview()
            }

            guard let image = Image("image\(tag)") else {
                return
            }
            image.constrainsProportions = true
            
            if image.width < image.height {
                image.width = 64
            } else {
                image.height = 64
            }

            imageContainer.add(image)
            imageContainer.border.radius = 4.0
            imageContainer.border.color = C4Purple
            imageContainer.border.width = 1.0
        }
    }

    public override init(frame: Rect) {
        super.init(frame: frame)

        self.addTapGestureRecognizer { _, _, _ in
            self.post("newPointWasSelected")
        }
    }

    func animate(dot: Circle) {
        let anim = ViewAnimation(duration: random01()*2.0 + 2.0) {
            switch random(below: 4) {
            case 1:
                dot.fillColor = C4Pink
            case 2:
                dot.fillColor = C4Blue
            case 3:
                dot.fillColor = C4Purple
            default:
                dot.fillColor = C4Grey
            }
        }

        anim.addCompletionObserver {
            wait(12.0) {
                self.animate(dot: dot)
            }
        }
        anim.animate()
    }
}
