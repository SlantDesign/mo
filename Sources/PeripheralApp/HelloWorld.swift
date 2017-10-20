//  Copyright © 2017 Slant. All rights reserved.

import Foundation
import MONode
import C4
import CocoaAsyncSocket

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let hello = PacketType(rawValue: 100000)
    static let world = PacketType(rawValue: 100001)
}

class HelloWorld: UniverseController, GCDAsyncSocketDelegate {
    let label = TextShape(text: "HELLO", font: Font(name: "AppleSDGothicNeo-Bold", size: 120)!)!

    override func setup() {
        label.center = Point(canvas.center.x + dx, canvas.center.y)
        canvas.add(label)

        #if os(iOS)
        _ = canvas.addTapGestureRecognizer { _, center, _ in
            if self.localize(point: center).x > self.canvas.center.x {
                self.send(type: .world)
            } else {
                self.send(type: .hello)
            }
        }
        #endif
    }

    func localize(point: Point) -> Point {
        return Point(point.x - dx, point.y)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.hello:
            hello()
        case PacketType.world:
            world()
        default:
            break
        }
    }

    //This is how you send a packet, with no data
    func send(type: PacketType) {
        let deviceId = socketManager.deviceID
        let packet = Packet(type: type, id: deviceId)
        socketManager.broadcastPacket(packet)
    }

    //Create your own functions to run
    func hello() {
        let anim = ViewAnimation(duration: 0.25) {
            let center = self.label.center
            self.label.text = "HELLO"
            self.label.center = center
            self.canvas.backgroundColor = C4Grey
        }
        anim.curve = .easeOut
        anim.animate()
    }

    func world() {
        let anim = ViewAnimation(duration: 0.25) {
            let center = self.label.center
            self.label.text = "WORLD"
            self.label.center = center
            self.canvas.backgroundColor = C4Blue
        }
        anim.curve = .easeOut
        anim.animate()
    }
}
