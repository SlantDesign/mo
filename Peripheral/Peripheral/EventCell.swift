//
//  EventCell.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import C4
import UIKit
import Foundation

class EventCell: UICollectionViewCell {
    var animatablePath: AnimatableCellPath! {
        didSet {
            createLayer()
            animate()
        }
    }
    var shapeLayer: ShapeLayer = ShapeLayer()

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
        shapeLayer.path = animatablePath.path
        shapeLayer.bounds = CGPathGetBoundingBox(animatablePath.path)
        shapeLayer.fillColor = animatablePath.fillColor
        shapeLayer.position = CGPoint(x: shapeLayer.bounds.midX, y: frame.height/2.0)
        shapeLayer.backgroundColor = CGColorCreateCopyWithAlpha(shapeLayer.fillColor, 0.1)
        layer.addSublayer(shapeLayer)
        ShapeLayer.disableActions = false
    }

    func setup() {
        backgroundColor = UIColor.clearColor()
        clipsToBounds = true

        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2.0
    }

    func animate() {
        shapeLayer.removeAllAnimations()
        let keyPath = "position"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = 30.0
        animation.beginTime = CACurrentMediaTime()
        animation.keyPath = keyPath
        animation.fromValue = NSValue(CGPoint: shapeLayer.position)
        animation.toValue = NSValue(CGPoint: CGPoint(x: shapeLayer.position.x - animatablePath.animationOffset, y: shapeLayer.position.y))
        animation.repeatCount = Float.infinity
        shapeLayer.addAnimation(animation, forKey:"Animate:\(keyPath)")
    }
}
