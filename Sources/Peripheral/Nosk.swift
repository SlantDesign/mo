//
//  Nosk.swift
//  MO
//
//  Created by travis on 2017-01-11.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket

class Nosk: UniverseController, GCDAsyncSocketDelegate {
    var connections = [[Int]]()
    var points = [NoskPoint]()
    var innerTargets = [Point]()
    var outerTargets = [Point]()
    var currentPointIndex = 0

    override func setup() {
        canvas.backgroundColor = Color(red: 0.14, green: 0.21, blue: 0.37, alpha: 1.0)
        createConnections()
        createTargets()
        createPoints()
        resetRemainingInnerLocations()
        resetRemainingOuterLocations()

    }

    func createPoints() {
        for i in 0..<connections.count {
            let p = NoskPoint()
            p.center = localize(point: canvas.center)
            p.interactionEnabled = true
            p.tag = i
            points.append(p)
            canvas.add(p)

            on(event: "newPointWasSelected", from: p) { sender in
                self.currentPointIndex = p.tag
                self.center(on: self.currentPointIndex)
            }
        }
    }

    func localize(point: Point) -> Point {
        var p = point
        p.x += dx
        return p
    }

    override func receivePacket(_ packet: Packet) {
        //do nothing
    }

    func createTargets() {
        var r = 280.0
        var dt =  2 * M_PI / Double(connections.count)

        for i in 0...Int(connections.count) {
            let angle = dt * Double(i)
            innerTargets.append(Point(r * cos(angle) + canvas.center.x + dx, r * sin(angle) + canvas.center.y))
        }

        r = 800.0
        dt = M_PI / Double(connections.count)
        for i in 0...(connections.count * 2) {
            let angle = dt * Double(i)
            outerTargets.append(Point(r * cos(angle) + canvas.center.x + dx, r * sin(angle) + canvas.center.y))
        }
    }

    var remainingInnerLocations = [Int]()
    func resetRemainingInnerLocations() {
        remainingInnerLocations.removeAll()
        for i in 0..<connections.count {
            remainingInnerLocations.append(i)
        }
    }

    var remainingOuterLocations = [Int]()
    func resetRemainingOuterLocations() {
        remainingOuterLocations.removeAll()
        for i in 0..<(connections.count*2) {
            remainingOuterLocations.append(i)
        }
    }

    func center(on index: Int) {
        let p = points[index]

        let anim = ViewAnimation(duration: 1.0) {
            let innerCircle = self.connections[p.tag]
            self.animate(innerCircle: innerCircle)
            self.animateOuterCircle(removing: innerCircle)
            p.center = self.localize(point: self.canvas.center)
            p.opacity = 1.0
            p.rotation = 0.0
        }
        anim.animate()
    }

    func animate(innerCircle: [Int]) {
        resetRemainingInnerLocations()
        for i in 0..<innerCircle.count {
            let index = innerCircle[i]
            let remainingTargetIndex = random(below: remainingInnerLocations.count)
            let targetIndex = remainingInnerLocations[remainingTargetIndex]
            remainingInnerLocations.remove(at: remainingTargetIndex)
            let position = innerTargets[targetIndex]

            let point = points[index]

            let dt =  2 * M_PI / Double(connections.count) * Double(targetIndex)

            let anim = ViewAnimation(duration: random01() + 0.25) {
                point.center = position
                point.opacity = 1.0
                point.rotation = dt
            }
            anim.animate()
        }
    }

    func animateOuterCircle(removing innerCircle: [Int]) {
        resetRemainingOuterLocations()
        var outerCircle = [Int]()
        for i in 0..<points.count {
            if !innerCircle.contains(i) {
                outerCircle.append(i)
            }
        }

        for i in 0..<outerCircle.count {
            let index = outerCircle[i]
            let point = points[index]

            if index != currentPointIndex {
                if canvas.bounds.contains(point.center) {
                    let remainingTargetIndex = random(below: remainingOuterLocations.count)
                    let targetIndex = remainingOuterLocations[remainingTargetIndex]
                    remainingOuterLocations.remove(at: remainingTargetIndex)
                    let position = outerTargets[targetIndex]
                    let anim = ViewAnimation(duration: 1.0 + random01() * 0.33) {
                        point.center = position
                        point.opacity = 1.0
                        point.rotation = 0.0
                    }
                    anim.animate()
                }
            }
        }
    }

    func createConnections() {
        for _ in 0...36 {
            connections.append([0])
        }
        connections[0]=[1, 2, 3, 36]
        connections[1]=[0, 2, 12, 13, 26, 36]
        connections[2]=[0, 1, 12, 14, 26]
        connections[3]=[0, 4]
        connections[4]=[3, 5, 6, 7, 8, 24, 28]
        connections[5]=[4, 6, 22, 24, 23, 36]
        connections[6]=[4, 5, 13, 14, 23, 24, 30, 36]
        connections[7]=[4, 8, 9, 36]
        connections[8]=[4, 7, 9, 10]
        connections[9]=[7, 8, 10]
        connections[10]=[8, 9, 11]
        connections[11]=[10, 12, 13, 14]
        connections[12]=[1, 2, 11, 13, 14]
        connections[13]=[1, 6, 11, 12, 14, 15]
        connections[14]=[1, 2, 6, 12, 13, 15, 16, 17, 18, 19]
        connections[15]=[13, 14, 16, 17, 18, 19]
        connections[16]=[14, 15, 17, 18, 19]
        connections[17]=[14, 15, 16, 18, 19]
        connections[18]=[14, 15, 16, 17, 19]
        connections[19]=[14, 15, 16, 17, 18]
        connections[20]=[21, 22, 24, 25, 26, 27, 35]
        connections[21]=[20, 25, 27, 35]
        connections[22]=[5, 20, 23, 24]
        connections[23]=[5, 6, 22]
        connections[24]=[4, 5, 6, 14, 20, 22, 25, 32]
        connections[25]=[20, 21, 24, 26, 27, 35]
        connections[26]=[1, 20, 25, 28, 35]
        connections[27]=[20, 21, 25, 28, 35]
        connections[28]=[4, 26, 29, 30, 31, 33]
        connections[29]=[28]
        connections[30]=[6, 28]
        connections[31]=[28, 32]
        connections[32]=[24, 31]
        connections[33]=[28, 34]
        connections[34]=[5, 6, 22, 33]
        connections[35]=[20, 21, 25, 26, 27]
        connections[36]=[0, 2, 5, 6, 23]
    }
}
