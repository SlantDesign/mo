//
//  Asteroid.swift
//  MO
//
//  Created by travis on 2017-01-30.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import SpriteKit
import MO
import C4

class Asteroid: SKSpriteNode {
    static let asteroidBeltMovementKey = "asteroidBeltMovementKey"
    static let physicsBodySize = CGSize(width: 100.0, height: 100.0)
    public var aura: SKSpriteNode?

    public convenience init(identifier: Int) {
        let texture = SKTexture(imageNamed: "Asteroid_0\(identifier % 4)")
        self.init(texture: texture, color: UIColor.clear, size: CGSize(width: 132.0, height: 132.0))
        name = "\(identifier)"
    }

    public convenience init(imageNamed name: String) {
        let texture = SKTexture(imageNamed: name)
        self.init(texture: texture, color: UIColor.clear, size: CGSize(width: 132.0, height: 132.0))
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }

    //broadcasts a message to create a new comet
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let n = name else {
            print("Couldn't extract name from asteroid")
            return
        }
        guard let identifier = Int(n) else {
            print("Couldn't convert name to Int")
            return
        }

        var d = Data()
        d.append(identifier)
        d.append(position)

        let packet = Packet(type: .comet, id: SocketManager.sharedManager.deviceID, payload: d)
        SocketManager.sharedManager.broadcastPacket(packet)
    }
}
