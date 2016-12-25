//  Copyright © 2015 C4. All rights reserved.

import C4
import Foundation
import UIKit

public enum GestureType : Int8 {
    case tap
    case swipe
    case longPress
    case pan
    case none
}

public struct Gesture {
    var type = GestureType.none
    var center = Point()
    var state = UIGestureRecognizerState.began
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

    func serialize() -> Data {
        let data = NSMutableData()
        var t = type.rawValue
        data.append(&t, length: MemoryLayout<Int8>.size)
        var c = center
        data.append(&c, length: MemoryLayout<Point>.size)
        var s = state.rawValue
        data.append(&s, length: MemoryLayout<UIGestureRecognizerState>.size)
        if type == GestureType.pan {
            var v = velocity
            data.append(&v, length: MemoryLayout<Vector>.size)
            var tr = translation
            data.append(&tr, length: MemoryLayout<Vector>.size)
        } else if type == GestureType.swipe {
            var d = direction
            data.append(&d, length: MemoryLayout<UISwipeGestureRecognizerDirection>.size)
        }
        return data as Data
    }
    
    init(_ data: Data) {
        var index = 0
        type = GestureType(rawValue: (data as NSData).bytes.bindMemory(to: Int8.self, capacity: data.count).pointee)!
        index += MemoryLayout<Int8>.size
        
        center = data.extract(Point.self, at: index)
        index += MemoryLayout<Point>.size
        
        state = UIGestureRecognizerState(rawValue: data.extract(Int.self, at: index)) ?? .possible
        index += MemoryLayout<UIGestureRecognizerState>.size
        
        if type == GestureType.pan {
            velocity = data.extract(Vector.self, at: index)
            index += MemoryLayout<Vector>.size
            translation = data.extract(Vector.self, at: index)
            index += MemoryLayout<Vector>.size
        } else if type == GestureType.swipe {
            direction = data.extract(UISwipeGestureRecognizerDirection.self, at: index)
            index += MemoryLayout<UISwipeGestureRecognizerDirection>.size
        }
    }
}
