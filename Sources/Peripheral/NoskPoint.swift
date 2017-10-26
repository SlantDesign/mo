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
    var imageContainer = Circle(frame: Rect(0, 0, 64, 64))

    public convenience override init() {
        self.init(frame: Rect(0, 0, 220, 64))

        imageContainer.origin.x = width/2.0 - 22.0
        imageContainer.lineWidth = 10.0
        imageContainer.strokeColor = white
        add(imageContainer)
    }
    
    public convenience init(title: String?, type: String?){
        self.init()
        self.titleString = title
        self.typeString = type
    }

    var title: TextShape?
    var writeup: TextShape?
    var titleString: String?
    var typeString: String?

    var tag = 0 {
        didSet {
            if let t = title {
                remove(t)
            }

            let font = Font(name: "Helvetica-Bold", size: 18)!
            if titleString != nil{
                title = TextShape(text: titleString!, font: font)!
            }
            else{
                title = TextShape(text: "ELEMENT \(tag)", font: font)!
            }
            title?.origin = Point(70.0 + width/2.0 - 22.0, 0.0)
            title?.lineWidth = 0.0
            title?.fillColor = white
            add(title)
            
            if typeString != nil{
                writeup = TextShape(text: typeString!, font: font.font(10))
            }
            else{
                writeup = TextShape(text: "This is a description of element \(tag).", font: font.font(10))
            }
            writeup?.origin = Point(70.0 + width/2.0 - 22.0, title!.height + 6)
            writeup?.lineWidth = 0.0
            writeup?.fillColor = white
            add(writeup)

            for v in imageContainer.view.subviews {
                v.removeFromSuperview()
            }
            let imnum = arc4random_uniform(50)
            guard let image = Image("image\(imnum)") else {
                return
            }
            image.constrainsProportions = true
            
            if image.width < image.height {
                image.width = 64
            } else {
                image.height = 64
            }

            let m = Circle(frame: imageContainer.frame)
            m.center = image.bounds.center
            image.mask = m
            image.center = imageContainer.bounds.center
            imageContainer.add(image)
        }
    }

    public override init(frame: Rect) {
        super.init(frame: frame)

        imageContainer.addTapGestureRecognizer { _, _, _ in
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
