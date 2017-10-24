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
import MapKit

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let handshake = PacketType(rawValue: 12340)
    static let locationRequest = PacketType(rawValue: 12342)
}

class HelloWorld: UniverseController, GCDAsyncSocketDelegate, MKMapViewDelegate{
    let socketManager = SocketManager.sharedManager
    //let label = TextShape(text: "HELLO", font: Font(name: "AppleSDGothicNeo-Bold", size: 120)!)!
    var mapView: MKMapView?
    var markerText: NSArray?
    var markers = [Marker]()
    var pairedDevice = 0
    var thisDevice = 0
    
    override func setup() {
        
        self.mapView = MKMapView(frame: CGRect(canvas.frame))
        mapView!.center = CGPoint(x: canvas.center.x + dx, y: canvas.center.y)
        self.mapView!.delegate = self
        do {
            if let file = Bundle.main.url(forResource: "MapPoints", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    markerText = object["locations"] as? NSArray
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        self.canvas.add(mapView!)
        mapView!.register(MarkerView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        if markerText != nil{
            for m in markerText!{
                guard let dict = m as? NSDictionary else{
                    continue
                }
                let title = dict["title"] as? String
                guard let placeName = dict["placeName"] as? String else{
                    print("e1")
                    continue
                }
                guard let type = dict["type"] as? String else{
                    print("e2")
                    continue
                }
                guard let latitude = dict["latitude"] as? String else{
                    print("e3")
                    continue
                }
                guard let longitude = dict["longitude"] as? String else{
                    print("e4")
                    continue
                }
                let marker = Marker(title: title, locName: placeName, type: type, lat: latitude, lon: longitude)
                markers.append(marker)
            }
        }
        
        mapView!.addAnnotations(markers)
        
        
        
        /*
        canvas.addTapGestureRecognizer { _, center, _ in
            if self.localize(point: center).x > self.canvas.center.x {
                self.send(type: .world)
            } else {
                self.send(type: .hello)
            }
        }
         */
    }
    

    func localize(point: Point) -> Point {
        return Point(point.x - dx, point.y)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.handshake:
            hello()
        case PacketType.locationRequest:
            world()
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

    //Create your own functions to run
    func hello() {
        let anim = ViewAnimation(duration: 0.25) {
            self.canvas.backgroundColor = C4Grey
        }
        anim.curve = .EaseOut
        anim.animate()
    }

    func world() {
        let anim = ViewAnimation(duration: 0.25) {
            self.canvas.backgroundColor = C4Blue
        }
        anim.curve = .EaseOut
        anim.animate()
    }
}
