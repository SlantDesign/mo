//
//  ArtistView.swift
//  Peripheral
//
//  Created by travis on 2016-04-05.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import Artists
import C4

var artistViewSetup: dispatch_once_t = 0

class ArtistView: View, UITextViewDelegate {
    static let shared = ArtistView(frame: Rect(UIScreen.mainScreen().bounds))
    let priority = DISPATCH_QUEUE_PRIORITY_HIGH

    var shapeView: View!
    var textView: UITextView!
    var exitButton: Circle!
    var event: Event? {
        didSet {
            loadEvent()

            loadShape()
        }
    }

    override init(frame: Rect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        backgroundColor = black.colorWithAlpha(0.90)
        dispatch_once(&artistViewSetup) {
            self.createShapeView()
            self.createTextView()
            self.createExitButton()
            dispatch_async(dispatch_get_main_queue()) {
                self.add(self.shapeView)
                self.add(self.textView)
                self.add(self.exitButton)
            }
        }
    }

    func createShapeView() {
        shapeView = View(frame: bounds)
    }

    func generateShapes(path: Path) -> [Shape] {
        ShapeLayer.disableActions = true
        var shapes = [Shape]()
        for _ in 0...3 {
            let shape = Shape(path)
            shape.fillColor = clear
            shape.strokeEnd = 0.0
            shape.opacity = 0.2
            shape.strokeColor = white
            shapes.append(shape)
       }
        ShapeLayer.disableActions = false
        return shapes
    }

    func loadShape() {
        for view in shapeView.view.subviews {
            view.removeFromSuperview()
        }

        guard let e = event else {
            print("Event is nil or invalid")
            return
        }

        guard let function = Artists.selectors[e.function] else {
            print("Could not extract function from \(e)")
            return
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let shapes = self.generateShapes(function())
            dispatch_async(dispatch_get_main_queue()) {
                self.animateShapes(shapes)
            }
        }
    }

    func animateShapes(shapes: [Shape]) {
        for i in 0..<shapes.count {
            let shape = shapes[i]
            shapeView.add(shape)
            let duration = 5.0
            short(shape, duration: duration, delay: 0.5 * Double(i))
        }
    }

    func short(shape: Shape, duration: Double, delay: Double) {
        let strokeEndOut = ViewAnimation(duration: duration) {
            shape.strokeEnd = 1.0
        }

        let strokeStartOut = ViewAnimation(duration: duration) {
            shape.strokeStart = 1.0
        }

        strokeEndOut.delay = delay
        strokeStartOut.delay = delay + duration * 0.2

        strokeEndOut.repeats = true
        strokeStartOut.repeats = true
        strokeEndOut.animate()
        strokeStartOut.animate()
    }

    func createTextView() {
        let f = Rect(20,20, self.width - 40, self.height-20)
        self.textView = UITextView(frame: CGRect(f))
        self.textView.contentInset = UIEdgeInsets(top: 740.0, left: 0, bottom: 20.0, right: 0)
        self.textView.font = UIFont(name: "Inconsolata", size: 17.0)
        self.textView.textColor = .lightGrayColor()
        self.textView.backgroundColor = .clearColor()
        self.textView.selectable = true
        self.textView.delegate = self
    }

    func createExitButton() {
        let circle = Circle(center: Point(47.5,47.5), radius: 47.5)
        circle.fillColor = Color(red: 0.173, green: 0.185, blue: 0.202, alpha: 0.400)
        circle.lineWidth = 0

        let xPath = UIBezierPath()
        xPath.moveToPoint(CGPointMake(73.3, 21.7))
        xPath.addLineToPoint(CGPointMake(21.6, 73.3))
        xPath.moveToPoint(CGPointMake(21.6, 21.7))
        xPath.addLineToPoint(CGPointMake(73.3, 73.3))

        let p = Path(path: xPath.CGPath)
        let x = Shape(p)
        x.fillColor = clear
        x.strokeColor = white
        circle.add(x)

        circle.center = Point(width - (x.width/2 + 40), x.height/2 + 40)
        circle.zPosition = 1000
        exitButton = circle

        self.exitButton.addTapGestureRecognizer { locations, center, state in
            self.hide()
        }
    }

    func loadEvent() {
        guard let e = event else {
            print("there is no event")
            return
        }

        let eventTitle = e.title
        var artists = ""
        for i in 0..<e.artists.count {
            artists += e.artists[i]
            if i < e.artists.count - 1 {
                artists += ", "
            }
        }

        let type = e.type
        let date = e.date
        let location = e.location
        let eventDescription = e.summary

        var completeString = ""
        if eventTitle != "" {
            completeString += eventTitle + "\n"
        }
        if artists != "" {
            completeString += artists + "\n"
        }
        if type != "" {
            completeString += type + "\n"
        }
        completeString += "\(date)\n"
        if location != "" {
            completeString += location + "\n"
        }
        if eventDescription != "" {
            completeString +=  "\n\(eventDescription)"
        }

        self.textView.text = completeString
        self.textView.contentInset = UIEdgeInsets(top: 740.0, left: 0, bottom: 20.0, right: 0)
        self.textView.contentOffset = CGPoint(x: 0, y: -740)
    }

    func reveal() {
        ViewAnimation(duration: 0.25) {
            self.opacity = 1.0
        }.animate()
    }

    func hide() {
        let a = ViewAnimation(duration: 0.25) {
            self.opacity = 0.0
        }
        a.animate()
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return false
    }
}