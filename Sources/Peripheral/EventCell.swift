// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import C4
import UIKit
import Foundation

class EventCell: UICollectionViewCell {
    var animatablePath: AnimatableCellPath? {
        didSet {
            createLayer()
            animate()
        }
    }
    var shapeLayer: ShapeLayer = ShapeLayer()
    var syncTimestamp: TimeInterval = 0 {
        didSet {
            animate()
        }
    }

    override func awakeFromNib() {
        setup()
    }

    var event: Event = Event()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init(path p: AnimatableCellPath) {
        self.init()
        self.animatablePath = p
        self.layer.addSublayer(shapeLayer)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder) not implemented")
    }

    func createLayer() {
        ShapeLayer.disableActions = true
        shapeLayer.removeFromSuperlayer()
        shapeLayer.removeAllAnimations()
        shapeLayer.path = animatablePath?.path
        shapeLayer.bounds = ((animatablePath?.path)?.boundingBox)!
        shapeLayer.fillColor = animatablePath?.fillColor
        shapeLayer.position = CGPoint(x: shapeLayer.bounds.midX, y: frame.height/2.0)
        shapeLayer.backgroundColor = (shapeLayer.fillColor)?.copy(alpha: 0.3)
        layer.addSublayer(shapeLayer)
        ShapeLayer.disableActions = false
    }

    func setup() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
    }

    func animate() {
        guard let animatablePath = animatablePath else {
            return
        }

        shapeLayer.removeAllAnimations()
        let keyPath = "position"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = 30.0
        animation.timeOffset = (CFAbsoluteTimeGetCurrent() - syncTimestamp).truncatingRemainder(dividingBy: animation.duration)
        animation.beginTime = CACurrentMediaTime()
        animation.keyPath = keyPath
        animation.fromValue = NSValue(cgPoint: shapeLayer.position)
        animation.toValue = NSValue(cgPoint: CGPoint(x: shapeLayer.position.x - animatablePath.animationOffset, y: shapeLayer.position.y))
        animation.repeatCount = Float.infinity
        shapeLayer.add(animation, forKey:"Animate:\(keyPath)")
    }
}
