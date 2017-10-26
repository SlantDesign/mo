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
    static let availabilityPing = PacketType(rawValue: 123450)
    static let connectionRequest = PacketType(rawValue: 123451)
    static let locationRequest = PacketType(rawValue: 123452)
    static let location = PacketType(rawValue: 123453)
}

class HelloWorld: UniverseController, GCDAsyncSocketDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate{
    let socketManager = SocketManager.sharedManager
    //let label = TextShape(text: "HELLO", font: Font(name: "AppleSDGothicNeo-Bold", size: 120)!)!
    var mapView: MKMapView?
    var markerText: NSArray?
    var markers = [Marker]()
    var pairedDevice = 0
    var isLeft = false
    var isMaster = false
    var initialized = false
    private var displayLink : CADisplayLink?
    private var startTime = 0.0
    private let animLength = 2.0
    private var g_ended = false
    private var lastloc: [Double] = [0, 0, 0, 0]
    var timer = Timer()
    
    override func setup() {
        
        self.mapView = MKMapView(frame: CGRect(x: CGFloat(canvas.frame.origin.x), y: CGFloat(canvas.frame.origin.y), width: CGFloat(canvas.frame.width*2.0), height: CGFloat(canvas.frame.height)))
        
        mapView!.center = CGPoint(x: canvas.origin.x + dx, y: canvas.center.y)
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
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(gestureRecognizer:)))
        mapDragRecognizer.delegate = self
        self.mapView!.addGestureRecognizer(mapDragRecognizer)
        
        /*
        canvas.addTapGestureRecognizer { _, center, _ in
            if self.localize(point: center).x > self.canvas.center.x {
                self.send(type: .availabilityPing)
            } else {
                self.send(type: .connectionRequest)
            }
        }*/
        
    }
    
    func startDisplayLink() {
        
        // make sure to stop a previous running display link
        stopDisplayLink()
        g_ended = false
        // create displayLink & add it to the run-loop
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink?.add(to: .main, forMode: .commonModes)
        
        // for Swift 2: displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
    }
    
    @objc func displayLinkDidFire() {
        
        var elapsed = CACurrentMediaTime() - startTime
        
        if g_ended && elapsed > animLength {
            stopDisplayLink()
            elapsed = animLength // clamp the elapsed time to the anim length
            g_ended = false
        }
        
        // do your animation logic here
        let deviceId = SocketManager.sharedManager.deviceID
        //let loc: [Double] = [mapView!.region.center.latitude, mapView!.region.center.longitude, mapView!.region.span.latitudeDelta, mapView!.region.span.longitudeDelta]
        let loc: [Double] = [mapView!.visibleMapRect.origin.x, mapView!.visibleMapRect.origin.y, mapView!.visibleMapRect.size.width, mapView!.visibleMapRect.size.height]
        //let loc: [Double] = [mapView!.centerCoordinate.latitude, mapView!.centerCoordinate.longitude]
        var flag = false
        for i in 0..<loc.count{
            if abs(loc[i]-lastloc[i])>100.0{
                flag = true
                break
            }
        }
        if !flag{
            return
        }
        lastloc = loc
        var data = Data()
        for l in loc{
            data.append(l)
        }
        let packet = Packet(type: PacketType.location, id: deviceId, payload: data)
        socketManager.broadcastPacket(packet)
    }
    
    // invalidate display link if it's non-nil, then set to nil
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool){
        if !self.initialized{
            self.initialized = true
            self.send(type: .availabilityPing)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        /*
        let deviceId = SocketManager.sharedManager.deviceID
        if(pairedDevice > deviceId){
            if (gestureRecognizer.state == UIGestureRecognizerState.began) {
                startDisplayLink()
            }
            
            if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
                startTime = CACurrentMediaTime()
                g_ended = true
            }
        }
 */
    }

    func localize(point: Point) -> Point {
        return Point(point.x - dx, point.y)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        if initialized{
            let deviceId = SocketManager.sharedManager.deviceID
            //print("I RECEIVED SOMETHING!!")
            //print(packet)
            switch packet.packetType {
            case PacketType.availabilityPing:
                if(deviceId > packet.id){
                    pairedDevice = packet.id
                    send(type: .connectionRequest)
                    print("Ping received from " + String(packet.id))
                    
                }
            case PacketType.connectionRequest:
                if pairedDevice == 0{
                    let payload = packet.payload
                    var id: Int = 0
                    (payload! as NSData).getBytes(&id)
                    if(deviceId == id){
                        mapView!.center = CGPoint(x: canvas.origin.x + dx + canvas.frame.width, y: canvas.center.y)
                        isLeft = true
                        pairedDevice = packet.id
                        let loc = CLLocationCoordinate2D(latitude: 65, longitude: -90)
                        let span = MKCoordinateSpan(latitudeDelta: 35.0, longitudeDelta: 0.0)
                        mapView!.setRegion(MKCoordinateRegionMake(loc, span), animated: true)
                        /*
                         print(mapView!.region.span.longitudeDelta)
                         let deadlineTime = DispatchTime.now() + .milliseconds(3000)
                         DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                         print(self.mapView!.region.span.longitudeDelta)
                         }
                         print("Location request received from " + String(packet.id))
                         */
                    }
                }
                else if(deviceId == packet.id){
                    let loc = CLLocationCoordinate2D(latitude: 65, longitude: -90)
                    let span = MKCoordinateSpan(latitudeDelta: 35.0, longitudeDelta: 0.0)
                    mapView!.setRegion(MKCoordinateRegionMake(loc, span), animated: true)
                }
            case PacketType.locationRequest:
                let deviceId = SocketManager.sharedManager.deviceID
                if(pairedDevice == packet.id){
                    let loc: [Double]
                    if(isMaster){
                        loc = [mapView!.visibleMapRect.origin.x, mapView!.visibleMapRect.origin.y, mapView!.visibleMapRect.size.width, mapView!.visibleMapRect.size.height]
                        
                    }
                    else{
                        mapView!.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: 65, longitude: -90), MKCoordinateSpan(latitudeDelta: 35.0, longitudeDelta: 0.0)), animated: true)
                        
                        loc = [27056589.516435899, 32510629.09588252, 88435308.476859599, 58956872.317906395]
                    }
                    lastloc = loc
                    var data = Data()
                    for l in loc{
                        data.append(l)
                    }
                    let packet = Packet(type: PacketType.location, id: deviceId, payload: data)
                    socketManager.broadcastPacket(packet)
                }
            case PacketType.location:
                if !isMaster && pairedDevice == packet.id && packet.payload != nil{
                    let data = packet.payload!
                    var index = 0
                    let center1 = data.extract(Double.self, at: 0)
                    index += MemoryLayout<Double>.size
                    let center2 = data.extract(Double.self, at: index)
                    index += MemoryLayout<Double>.size
                    let span1 = data.extract(Double.self, at: index)
                    index += MemoryLayout<Double>.size
                    let span2 = data.extract(Double.self, at: index)
                    //print("center1: \(center1), center2: \(center2), span1: \(span1), span2: \(span2)")
                    //mapView!.setCenter(CLLocationCoordinate2DMake(center1, center2), animated: false)
                    //mapView!.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(center1, center2), MKCoordinateSpanMake(span1, span2)), animated: false)
                    let mapRect = MKMapRect(origin: MKMapPoint(x: center1, y: center2), size: MKMapSize(width: span1, height: span2))
                    mapView!.goto(rect: mapRect, duration: 0.2)
                    //mapView!.camera.centerCoordinate.latitude = center1
                    //mapView!.camera.centerCoordinate.longitude = center2
                    //mapView!.camera.centerCoordinate = CLLocationCoordinate2D(latitude: center1, longitude: center2)
                    //mapView!.camera.altitude = span1
                }
            default:
                print("Invalid packet type")
                break
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        if(isMaster){
            stopDisplayLink()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        if(isMaster){
            startDisplayLink()
        }
    }
 

    //This is how you send a packet, with no data
    func send(type: PacketType) {
        let deviceId: Int
        var data: NSMutableData? = nil
        switch type{
        case PacketType.availabilityPing:
            deviceId = SocketManager.sharedManager.deviceID
            let deadlineTime = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                if self.pairedDevice == 0{
                    self.send(type: .availabilityPing)
                }
            }
        case PacketType.connectionRequest:
            deviceId = SocketManager.sharedManager.deviceID
            data = NSMutableData()
            data!.append(&pairedDevice, length: MemoryLayout<Int>.size)
        case PacketType.locationRequest:
            deviceId = SocketManager.sharedManager.deviceID
        default:
            return
        }
        let packet: Packet
        if data != nil {
            packet = Packet(type: type, id: deviceId, payload: data as Data?)
        }
        else {
            packet = Packet(type: type, id: deviceId)
        }
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
    
    static func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMaster = true
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timeoutAction), userInfo: nil, repeats: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMaster = true
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timeoutAction), userInfo: nil, repeats: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMaster = true
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timeoutAction), userInfo: nil, repeats: false)
    }
    
    @objc func timeoutAction(){
        timer.invalidate()
        isMaster = false
        stopDisplayLink()
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: PacketType.locationRequest, id: deviceId)
        socketManager.broadcastPacket(packet)
        
    }
}

extension MKMapView {
    func goto(rect:MKMapRect, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, animations: {
            self.setVisibleMapRect(rect, animated: true)
        }, completion: nil)
    }
}
