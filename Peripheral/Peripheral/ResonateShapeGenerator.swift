//
//  ResonateShapeGenerator.swift
//  Peripheral
//
//  Created by travis on 2016-04-07.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import C4

class ResonateShapeGenerator {
    let paths = [resSquare(), resRectangle(), resLine(), resCross(), resT(), resO(), resU(), resArc(), resHardArc(), resPlus(), resZ(), resL(), resHardArcLarge()]
    let color0 = Color(red:0.224, green:0.224, blue: 0.224, alpha: 1)
    let color1 = Color(red:0.431, green:0.431, blue: 0.431, alpha: 1)

    static let shared = ResonateShapeGenerator()

    func createRandomShape(center: Point) -> (Gradient, NSData) {
        let angle = M_PI_4 * Double(random(below: 8))
        let pathIndex = random(below: paths.count)
        return generateShapeFrom(center, pathIndex: pathIndex, angle: angle)
    }

    func generateShapeFrom(center: Point, pathIndex: Int, angle: Double) -> (Gradient, NSData) {
        ShapeLayer.disableActions = true
        let shape = Shape(paths[pathIndex])
        shape.lineWidth = 10.0
        shape.lineCap = .Square
        shape.fillColor = clear
        shape.lineJoin = .Miter
        shape.strokeEnd = 0.0

        let inset = CGFloat(-shape.lineWidth/2.0)
        let insetFrame = CGRectInset(shape.view.bounds, inset, inset)
        let gradient = Gradient(frame: Rect(insetFrame))
        shape.origin = Point(Double(-inset), Double(-inset))

        gradient.colors = [color0, color1]
        gradient.startPoint = Point(0,0)
        gradient.endPoint = Point(1,0)
        gradient.mask = shape
        gradient.center = center
        gradient.transform.rotate(angle)
        ShapeLayer.disableActions = false

        let reveal = ViewAnimation(duration: 2.0) {
            shape.strokeEnd = 1.0
        }
        reveal.delay = 0.25
        reveal.curve = .EaseInOut

        let hide = ViewAnimation(duration: 2.0) {
            shape.opacity = 0.0
        }
        hide.delay = 1.0

        let seq = ViewAnimationSequence(animations: [reveal, hide])
        seq.addCompletionObserver {
            gradient.removeFromSuperview()
        }
        seq.animate()

        var p = center
        var pi = pathIndex
        var a = angle
        let data = NSMutableData()
        data.appendBytes(&p, length: sizeof(Point))
        data.appendBytes(&pi, length: sizeof(Int))
        data.appendBytes(&a, length: sizeof(Double))

        return (gradient, data)
    }

    func rebuildShape(data: NSData) -> Gradient {
        var index = 0
        let point = UnsafePointer<Point>(data.bytes).memory
        index += sizeof(Point)

        let pathIndex = UnsafePointer<Int>(data.bytes + index).memory
        index += sizeof(Int)

        let angle = UnsafePointer<Double>(data.bytes + index).memory
        return generateShapeFrom(point, pathIndex: pathIndex, angle: angle).0
    }
}

func resSquare() -> Path {
    //// resSquare Drawing
    let bezier = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 194, height: 194))
    return Path(path: bezier.CGPath)
}

func resRectangle() -> Path {
    //// resRectangle Drawing
    let bezier = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 254.1, height: 128.6))
    return Path(path: bezier.CGPath)
}

func resLine() -> Path {
    //// resLine Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 214.5, y: 0))
    bezier.addLineToPoint(CGPoint(x: 0, y: 214.5))
    return Path(path: bezier.CGPath)
}

func resCross() -> Path {
    //// Group
    //// resCross Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 23, y: 0))
    bezier.addLineToPoint(CGPoint(x: 23, y: 125))
    bezier.moveToPoint(CGPoint(x: 0, y: 100.4))
    bezier.addLineToPoint(CGPoint(x: 46, y: 100.4))
    return Path(path: bezier.CGPath)
}

func resT() -> Path {
    //// Group 2
    //// resT Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 65.1, y: -0))
    bezier.addLineToPoint(CGPoint(x: 65.1, y: 125))
    bezier.moveToPoint(CGPoint(x: 0, y: 125.4))
    bezier.addLineToPoint(CGPoint(x: 130.2, y: 125.4))
    return Path(path: bezier.CGPath)
}

func resO() -> Path {
    //// resO Drawing
    let bezier = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 225, height: 225))
    return Path(path: bezier.CGPath)
}

func resC() -> Path {
    //// resC Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 101, y: 50.5))
    bezier.addCurveToPoint(CGPoint(x: 50.5, y: 101), controlPoint1: CGPoint(x: 101, y: 78.4), controlPoint2: CGPoint(x: 78.4, y: 101))
    bezier.addCurveToPoint(CGPoint(x: 0, y: 50.5), controlPoint1: CGPoint(x: 22.6, y: 101), controlPoint2: CGPoint(x: 0, y: 78.4))
    bezier.addCurveToPoint(CGPoint(x: 50.5, y: 0), controlPoint1: CGPoint(x: 0, y: 22.6), controlPoint2: CGPoint(x: 22.6, y: 0))
    return Path(path: bezier.CGPath)
}

func resU() -> Path {
    //// resU Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 154, y: 0))
    bezier.addLineToPoint(CGPoint(x: 49.8, y: 0))
    bezier.addCurveToPoint(CGPoint(x: 0, y: 49.8), controlPoint1: CGPoint(x: 22.3, y: 0), controlPoint2: CGPoint(x: 0, y: 22.3))
    bezier.addCurveToPoint(CGPoint(x: 49.8, y: 99.6), controlPoint1: CGPoint(x: 0, y: 77.3), controlPoint2: CGPoint(x: 22.3, y: 99.6))
    bezier.addLineToPoint(CGPoint(x: 154, y: 99.6))
    return Path(path: bezier.CGPath)
}

func resArc() -> Path {
    //// resArc Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 68, y: 136))
    bezier.addCurveToPoint(CGPoint(x: 0, y: 68), controlPoint1: CGPoint(x: 30.4, y: 136), controlPoint2: CGPoint(x: 0, y: 105.6))
    bezier.addCurveToPoint(CGPoint(x: 68, y: 0), controlPoint1: CGPoint(x: 0, y: 30.4), controlPoint2: CGPoint(x: 30.4, y: 0))
    return Path(path: bezier.CGPath)
}

func resHardArc() -> Path {
    //// resHardArc Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 0, y: 0))
    bezier.addCurveToPoint(CGPoint(x: 41.5, y: 41.6), controlPoint1: CGPoint(x: 0, y: 22.9), controlPoint2: CGPoint(x: 18.6, y: 41.6))
    bezier.addLineToPoint(CGPoint(x: 66.7, y: 41.6))
    bezier.addLineToPoint(CGPoint(x: 66.7, y: 0))

    let path = Path(path: bezier.CGPath)
    let scale = 2.5
    let t = Transform.makeScale(scale, scale)
    path.transform(t)
    return Path(path: bezier.CGPath)
}


func resHardArcLarge() -> Path {
    //// resHardArc Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 0, y: 0))
    bezier.addCurveToPoint(CGPoint(x: 41.5, y: 41.6), controlPoint1: CGPoint(x: 0, y: 22.9), controlPoint2: CGPoint(x: 18.6, y: 41.6))
    bezier.addLineToPoint(CGPoint(x: 66.7, y: 41.6))
    bezier.addLineToPoint(CGPoint(x: 66.7, y: 0))
    let path = Path(path: bezier.CGPath)
    let scale = 5.0
    let t = Transform.makeScale(scale, scale)
    path.transform(t)
    return path
}

func resPlus() -> Path {
    //// Group 3
    //// resPlus Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 169, y: 84.5))
    bezier.addLineToPoint(CGPoint(x: 0, y: 84.5))
    bezier.moveToPoint(CGPoint(x: 84.5, y: 0))
    bezier.addLineToPoint(CGPoint(x: 84.5, y: 169))
    return Path(path: bezier.CGPath)
}

func resZ() -> Path {
    //// resZ Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 0, y: 0))
    bezier.addLineToPoint(CGPoint(x: 0, y: 53.3))
    bezier.addLineToPoint(CGPoint(x: 154, y: 53.3))
    bezier.addLineToPoint(CGPoint(x: 154, y: 102.3))
    return Path(path: bezier.CGPath)
}

func resL() -> Path {
    //// resL Drawing
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 0, y: 0))
    bezier.addLineToPoint(CGPoint(x: 0, y: 77))
    bezier.addLineToPoint(CGPoint(x: 184, y: 77))
    return Path(path: bezier.CGPath)
}
