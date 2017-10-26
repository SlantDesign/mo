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
        do {
            if let file = Bundle.main.url(forResource: "vhec_data", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    createConnections(object)
                    createTargets()
                    createPoints(object)
                    resetRemainingInnerLocations()
                    resetRemainingOuterLocations()
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        

    }

    func createPoints(_ dict: [String: Any]) {
        for i in 0..<connections.count {
            let str: String = String(i)
            var title: String? = nil
            var type: String? = nil
            if let item = dict[str] as? [String: Any]{
                if let s1 = item["title"] as? String{
                    title = s1
                }
                if let s2 = item["type"] as? String{
                    type = s2
                }
            }
            let p = NoskPoint(title: title, type: type)
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

    func createConnections(_ dict: Dictionary<String, Any>) {
        var i = 0
        while(true){
            let str: String = String(i)
            guard let item = dict[str] as? [String: Any] else{
                break
            }
            guard let related = item["related"] as? [Int] else{
                break
            }
            connections.append(related)
            i = i+1
        }
    }
}
