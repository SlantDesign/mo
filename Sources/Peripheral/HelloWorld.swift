//
//  HelloMO.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import MO
import C4
import CocoaAsyncSocket

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let hello = PacketType(rawValue: 100000)
    static let world = PacketType(rawValue: 100001)
}

class HelloWorld: UniverseController, GCDAsyncSocketDelegate, UIScrollViewDelegate {
    let socketManager = SocketManager.sharedManager
    let scrollView = UIScrollView()
    var locations: NSArray!
    var schools = [School]()
    

    override func setup() {
        
        canvas.backgroundColor = black
        
        //Read input file
        do {
            if let file = Bundle.main.url(forResource: "MapPoints", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    locations = object["locations"] as? NSArray
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
        //initialize color picker
        let picker = ColorPicker()
        
        //Create array of schools
        for location in locations{
            let loc = location as! NSDictionary
            if loc["type"] as? String != "School"{
                continue
            }
            let start = Int(loc["start"] as! String)!
            let end = Int(loc["end"] as! String)!
            let name = loc["locationName"] as! String
            schools.append(School(name.replacingOccurrences(of: "&#39;", with: "'"), start, end, picker.next(), canvas.height))
        }
        
        //Calculate date span
        var earliest = 2017
        var latest = 1900
        for s in schools{
            if s.start < earliest{
                earliest = s.start
            }
            if s.end > latest{
                latest = s.end
            }
        }
        
        //Load start, end and total vectors
        var starts = [[School]]()
        var ends = [[School]]()
        var totals = [[School]]()
        for _ in earliest...latest{
            starts.append([School]())
            ends.append([School]())
            totals.append([School]())
        }
        for s in schools{
            starts[s.start-earliest].append(s)
            ends[s.end-earliest].append(s)
        }
        
        
        //Calculate total number of schools at any time
        for y in 0...latest-earliest{
            if y>0{
                for s in totals[y-1]{
                    totals[y].append(s)
                }
            }
            for s in starts[y].reversed(){
                totals[y].append(s)
            }
            for s in ends[y]{
                totals[y].remove(at: totals[y].index(of: s)!)
            }
        }
        
        
        //Add the scroll view
        scrollView.frame = CGRect(canvas.frame)
        scrollView.center = CGPoint(x: canvas.center.x + dx, y: canvas.center.y)
        canvas.add(scrollView)
        scrollView.contentSize = CGSize(width: CGFloat(canvas.frame.width*Double(latest-earliest+1)/2.0), height: CGFloat(canvas.frame.height))
        scrollView.delegate = self
        
        var lineStarts = [[Point]]()
        var lineEnds = [[Point]]()
        var lineWidths = [[Double]]()
        for _ in schools{
            lineEnds.append([Point]())
            lineStarts.append([Point]())
            lineWidths.append([Double]())
        }
        for y in 0...latest-earliest{
            //Add background lines
            for (i, s) in totals[y].enumerated(){
                let lineWidth = canvas.height/Double(max(totals[y].count, 10))
                let h = (canvas.height)*(1.0 - Double(i)/Double(totals[y].count))*min(Double(totals[y].count)/10.0, 1.0) - lineWidth/2.0
                let lineStart = Point(canvas.width*(Double(y)*0.5 + 0.25) + 100, h)
                let lineEnd = Point(canvas.width*(Double(y+1)*0.5 + 0.25) - 100, h)
                lineStarts[schools.index(of: s)!].append(lineStart)
                lineEnds[schools.index(of: s)!].append(lineEnd)
                lineWidths[schools.index(of: s)!].append(lineWidth)
                let line = Line(lineStart, lineEnd)
                line.lineWidth = lineWidth
                line.strokeColor = Color(s.color)
                scrollView.add(line)
            }
        }
        
        //Create joining lines
        for (i, s) in schools.enumerated(){
            if lineStarts[i].count > 0{
                let path = Path()
                let delta_x = 100.0
                let count = max(starts[s.start-earliest].count, 10)
                let labelCenter = Point(lineStarts[i][0].x + 40, canvas.height*(Double(starts[s.start-earliest].index(of: s)!) + 0.5)/Double(count))
                let labelWidth = canvas.height/Double(count)
                path.moveToPoint(Point(labelCenter.x, labelCenter.y + labelWidth/2.0))
                path.addCurveToPoint(Point(labelCenter.x + delta_x, lineStarts[i][0].y + lineWidths[i][0]/2.0), control1: Point(labelCenter.x + delta_x/2, labelCenter.y + labelWidth/2.0), control2: Point(labelCenter.x + delta_x/2, lineStarts[i][0].y + lineWidths[i][0]/2.0))
                path.addLineToPoint(Point(labelCenter.x + delta_x, lineStarts[i][0].y - lineWidths[i][0]/2.0))
                path.addCurveToPoint(Point(labelCenter.x, labelCenter.y - labelWidth/2.0), control1: Point(labelCenter.x + delta_x/2, lineStarts[i][0].y - lineWidths[i][0]/2.0), control2: Point(labelCenter.x + delta_x/2, labelCenter.y - labelWidth/2.0))
                path.closeSubpath()
                let shape = Shape()
                shape.path = path
                shape.lineWidth = 0.0
                shape.fillColor = Color(s.color)
                scrollView.add(shape)
                //Add lines between years
                if lineStarts[i].count > 1{
                    for j in 1..<lineStarts[i].count{
                        let path = Path()
                        let delta_x = lineStarts[i][j].x - lineEnds[i][j-1].x
                        let delta_y = lineStarts[i][j].y - lineEnds[i][j-1].y
                        path.moveToPoint(Point(lineEnds[i][j-1].x, lineEnds[i][j-1].y + lineWidths[i][j-1]/2.0))
                        path.addCurveToPoint(Point(lineStarts[i][j].x, lineStarts[i][j].y + lineWidths[i][j]/2.0), control1: Point(lineEnds[i][j-1].x + delta_x/2, lineEnds[i][j-1].y + lineWidths[i][j-1]/2.0), control2: Point(lineStarts[i][j].x - delta_x/2, lineStarts[i][j].y + lineWidths[i][j]/2.0))
                        path.addLineToPoint(Point(lineStarts[i][j].x, lineStarts[i][j].y - lineWidths[i][j]/2.0))
                        path.addCurveToPoint(Point(lineEnds[i][j-1].x, lineEnds[i][j-1].y - lineWidths[i][j-1]/2.0), control1: Point(lineStarts[i][j].x - delta_x/2, lineStarts[i][j].y - lineWidths[i][j]/2.0), control2: Point(lineEnds[i][j-1].x + delta_x/2, lineEnds[i][j-1].y - lineWidths[i][j-1]/2.0))
                        path.closeSubpath()
                        let shape = Shape()
                        shape.path = path
                        shape.lineWidth = 0.0
                        shape.fillColor = Color(s.color)
                        scrollView.add(shape)
                    }
                }
            }
        }
        
        for y in 0...latest-earliest{
            //Add starting labels
            for (i, s) in starts[y].enumerated(){
                let count = max(starts[y].count, 10)
                let label = s.getLabel(count)
                label.center = Point(canvas.width*(Double(y)*0.5 + 0.25), canvas.height*(Double(i) + 0.5)/Double(count))
                for v in label.view.subviews{
                    v.center = CGPoint(x: 150.0, y: canvas.height*0.5/Double(count))
                }
                scrollView.add(label)
            }
        }
        
        
        
    }

    func localize(point: Point) -> Point {
        return Point(point.x - dx, point.y)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.hello:
            break
        case PacketType.world:
            break
        default:
            break
        }
    }

    //This is how you send a packet, with no data
    func send(type: PacketType) {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: type, id: deviceId)
        socketManager.broadcastPacket(packet)
    }
}
