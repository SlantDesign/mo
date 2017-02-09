//
//  SunSprite.swift
//  MO
//
//  Created by travis on 2017-02-08.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import MO
import C4

public protocol SunSpriteDelegate {
    func randomEffect(at point: CGPoint)
}

class SunSprite: SKSpriteNode {
    var sunSpriteDelegate: SunSpriteDelegate?
    var image: Image?
    var data: UnsafePointer<UInt8>?
    var imageData: CFData?
    var imageScale: CGFloat = 1.0

    public convenience init(imageNamed name: String) {
        let t = SKTexture(imageNamed: name)
        self.init(texture: t)
        image = Image(name)

        guard let cgimg: CGImage = image?.cgImage else {
            print("Could not create cgimage")
            return
        }

        guard let scale = image?.uiimage.scale else {
            print("Could not get scale")
            return
        }
        imageScale = scale
        print(imageScale)
        print(image?.size)
        guard let imageProvider = cgimg.dataProvider else {
            print("Could not create imageProvider")
            return
        }

        let imageData = imageProvider.data
        self.imageData = imageData
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            var p = t.location(in: self)
            p.x += self.frame.width/2.0
            p.y = self.frame.height-p.y
            if !isTransparent(at: Point(p)) {
                sunSpriteDelegate?.randomEffect(at: convertToSKViewCoordinates(t.location(in: self.scene?.view)))
            }
        }
    }

    func convertToSKViewCoordinates(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - 368.0, y: 512.0 - point.y)
    }

    public func isTransparent(at point: Point) -> Bool {
        let position = 4*(Int(self.frame.width * 2.0) * Int(point.y * 2.0) + Int(point.x * 2.0))
        guard let value = data?[position+3] else {
            print("Could not get value from data")
            return false
        }
        return Double(value)/255.0 == 0.0
    }
}
