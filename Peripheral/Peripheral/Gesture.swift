//  Copyright © 2015 C4. All rights reserved.

import Foundation
import UIKit

public enum GestureType : Int8 {
    case Tap
    case Swipe
    case LongPress
    case Pan
    case None
}

public struct Gesture {
    var type = GestureType.None
    var center = Point()
    var state = UIGestureRecognizerState.Began
    var velocity : Vector?
    var translation : Vector?
    var direction : UISwipeGestureRecognizerDirection?
    
    public init(type t: GestureType, center c: Point, state s: UIGestureRecognizerState, velocity v: Vector, translation tr: Vector) {
        type = t
        center = c
        state = s
        velocity = v
        translation = tr
    }

    public init(type t: GestureType, center c: Point, state s: UIGestureRecognizerState, direction d: UISwipeGestureRecognizerDirection) {
        type = t
        center = c
        state = s
        direction = d
    }

    public init(type t: GestureType, center c: Point, state s: UIGestureRecognizerState) {
        type = t
        center = c
        state = s
    }

    func serialize() -> NSData {
        let data = NSMutableData()
        var t = type.rawValue
        data.appendBytes(&t, length: sizeof(Int8))
        var c = center
        data.appendBytes(&c, length: sizeof(Point))
        var s = state.rawValue
        data.appendBytes(&s, length: sizeof(UIGestureRecognizerState))
        if type == GestureType.Pan {
            var v = velocity
            data.appendBytes(&v, length: sizeof(Vector))
            var tr = translation
            data.appendBytes(&tr, length: sizeof(Vector))
        } else if type == GestureType.Swipe {
            var d = direction
            data.appendBytes(&d, length: sizeof(UISwipeGestureRecognizerDirection))
        }
        return data
    }
    
    init(_ data: NSData) {
        var index = 0
        type = GestureType(rawValue: UnsafePointer<Int8>(data.bytes).memory)!
        index += sizeof(Int8)
        
        center = UnsafePointer<Point>(data.bytes + index).memory
        index += sizeof(Point)
        
        state = UIGestureRecognizerState(rawValue: UnsafePointer<Int>(data.bytes+index).memory)!
        index += sizeof(UIGestureRecognizerState)
        
        if type == GestureType.Pan {
            velocity = UnsafePointer<Vector>(data.bytes + index).memory
            index += sizeof(Vector)
            translation = UnsafePointer<Vector>(data.bytes + index).memory
            index += sizeof(Vector)
        } else if type == GestureType.Swipe {
            direction = UnsafePointer<UISwipeGestureRecognizerDirection>(data.bytes + index).memory
            index += sizeof(UISwipeGestureRecognizerDirection)
        }
    }
}