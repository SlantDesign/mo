// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import Foundation
import C4

var artistViewSetup: Int = 0

class ArtistView: View, UITextViewDelegate {
    static let shared = ArtistView(frame: Rect(UIScreen.main.bounds))
    let priority = DispatchQueue.init(label: "priorityQueue", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)

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
        createShapeView()
        createTextView()
        createExitButton()
        add(shapeView)
        add(textView)
        add(exitButton)
    }

    func createShapeView() {
        shapeView = View(frame: bounds)
    }

    func generateShapes(_ path: Path) -> [Shape] {
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

        guard event != nil else {
            print("Event is nil or invalid")
            return
        }

//        guard let function = Artists.selectors[e.function] else {
//            print("Could not extract function from \(e)")
//            return
//        }

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
//            let shapes = self.generateShapes(function())
//            dispatch_async(dispatch_get_main_queue()) {
//                self.animateShapes(shapes)
//            }
//        }
    }

    func animateShapes(_ shapes: [Shape]) {
        for i in 0..<shapes.count {
            let shape = shapes[i]
            shapeView.add(shape)
            let duration = 5.0
            short(shape, duration: duration, delay: 0.5 * Double(i))
        }
    }

    func short(_ shape: Shape, duration: Double, delay: Double) {
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
        self.textView.textColor = .lightGray
        self.textView.backgroundColor = .clear
        self.textView.isSelectable = true
        self.textView.delegate = self
    }

    func createExitButton() {
        let circle = Circle(center: Point(47.5,47.5), radius: 47.5)
        circle.fillColor = Color(red: 0.173, green: 0.185, blue: 0.202, alpha: 0.400)
        circle.lineWidth = 0

        let xPath = UIBezierPath()
        xPath.move(to: CGPoint(x:73.3, y:21.7))
        xPath.addLine(to: CGPoint(x:21.6, y:73.3))
        xPath.move(to: CGPoint(x:21.6, y:21.7))
        xPath.addLine(to: CGPoint(x:73.3, y:73.3))

        let p = Path(path: xPath.cgPath)
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

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(abbreviation: "PST")

        completeString += "\(df.string(from: date as Date))\n"
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

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
