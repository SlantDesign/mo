//
//  Grid.swift
//  MO
//
//  Created by travis on 2017-01-11.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket

class Grid: UniverseController, GCDAsyncSocketDelegate {
    let socketManager = SocketManager.sharedManager
    let highlight = Rectangle(frame: Rect(0,0,64,64))
    var gridImages = [GridImage]()

    override func setup() {
        canvas.backgroundColor = black
        for x in 0..<12 {
            for y in 0..<16 {
                var r = Rect(x*64,y*64,64,64)
                r.origin = localize(point: r.origin)
                let image = GridImage(frame: r)
                gridImages.append(image)
                canvas.add(image)
            }
        }

        highlight.fillColor = clear
        highlight.border.width = 5
        highlight.border.color = C4Blue
        highlight.hidden = true
        canvas.add(highlight)

        canvas.addPanGestureRecognizer { _, center, _, _, state in
            if state == .began || state == .changed {
                self.highlight.hidden = false
            } else {
                self.highlight.hidden = true
            }

            for gi in self.gridImages {
                if gi.frame.contains(center) && self.highlight.center != gi.center{
                    ViewAnimation(duration: 0.25) {
                        self.highlight.center = gi.center
                    }.animate()
                    break
                }
            }
        }
    }

    func localize(point: Point) -> Point {
        return Point(point.x + dx, point.y)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
    }
}

class GridImage: View {
    var current: Image?
    var next: Image?
    var timer: C4.Timer?

    override init(frame: Rect) {
        super.init(frame: frame)

        guard let new = randomImage() else {
            print("couldn't create a current image on initialization")
            return
        }
        interactionEnabled = false
        self.masksToBounds = true

        new.constrainsProportions = true

        let setHeight = new.width > new.height
        if setHeight {
            new.height = self.height
        } else {
            new.width = self.width
        }

        current = new
        add(current)

        wait(random01()*20.0) {
            self.flip()
        }
    }

    func flip() {
        guard let new = randomImage() else {
            print("couldn't create a new image on initialization")
            return
        }

        new.constrainsProportions = true

        let setHeight = new.width > new.height
        if setHeight {
            new.height = self.height
        } else {
            new.width = self.width
        }

        next = new

        UIView.transition(from: current!.view, to: next!.view, duration: random01()*3.0 + 1.0, options: randomOptions()) { _ in
            self.current?.removeFromSuperview()
            self.current = self.next
            wait(random01()*35.0 + 5.0) {
                self.flip()
            }
        }
    }

    func randomOptions() -> UIViewAnimationOptions {
        switch random(below: 4) {
        case 0:
            return .transitionFlipFromTop
        case 1:
            return .transitionFlipFromRight
        case 2:
            return .transitionFlipFromLeft
        default:
            return .transitionFlipFromBottom
        }
    }

    func randomImage() -> Image? {
        let index = random(below: 300)
        return Image("image\(index)")
    }
}
