// Copyright © 2015 JABT Labs Inc. All rights reserved.

import Foundation
import QuartzCore

@objc(C4SerialAnimation)
public class SerialAnimation: NSObject, NSCoding, NSCopying {
    public var object: AnyObject?
    public var from: AnyObject?
    public var to: AnyObject?
    public var duration = NSTimeInterval(0.25)
    public var curve: CAMediaTimingFunction?


    override init() {
        super.init()
    }
    // MARK: NSCoding

    public convenience init(object: AnyObject, from: AnyObject, to: AnyObject, duration: NSTimeInterval = 0.25, curve: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)) {
        self.init()
        self.object = object
        self.from = from
        self.to = to
        self.duration = duration
        self.curve = curve
    }

    private struct SerializationKeys {
        static let object = "object"
        static let from = "from"
        static let to = "to"
        static let duration = "duration"
        static let curve = "curve"
    }

    public required init?(coder: NSCoder) {
        from = coder.decodeObjectForKey(SerializationKeys.from)
        to = coder.decodeObjectForKey(SerializationKeys.to)
        object = coder.decodeObjectForKey(SerializationKeys.object)
        duration = coder.decodeDoubleForKey(SerializationKeys.duration)
        curve = coder.decodeObjectForKey(SerializationKeys.curve) as? CAMediaTimingFunction
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(object, forKey: SerializationKeys.object)
        coder.encodeObject(from, forKey: SerializationKeys.from)
        coder.encodeObject(to, forKey: SerializationKeys.to)
        coder.encodeDouble(duration, forKey: SerializationKeys.duration)
        coder.encodeObject(curve, forKey: SerializationKeys.curve)
    }


    // MARK: NSCopying

    public func copyWithZone(zone: NSZone) -> AnyObject  {
        let copy = SerialAnimation(object: self.object!, from: self.from!, to: self.to!, duration: self.duration, curve: self.curve!)
        return copy
    }
}


// MARK: Description

extension SerialAnimation {
    public override var description: String {
        return "Animation\n" +
               "         object: \(object)\n" +
               "           from: \(from)\n" +
               "             to: \(to)\n" +
               "       duration: \(duration)\n" +
               "         curve: \(curve)"
    }
}
