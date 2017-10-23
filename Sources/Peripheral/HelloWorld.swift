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
import CoreLocation
import CoreBluetooth
var region: CLBeaconRegion!
var peripheral: CBPeripheralManager!
var peripheralData: NSDictionary!
var locManager: CLLocationManager!

//For any new commands you want to send
//Create an extension with a unique series of integers
extension PacketType {
    static let master = PacketType(rawValue: 100000)
    static let distance = PacketType(rawValue: 100001)
    static let message = PacketType(rawValue: 100002)
}

class HelloWorld: UniverseController, GCDAsyncSocketDelegate, CBPeripheralManagerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    let socketManager = SocketManager.sharedManager
    let label = TextShape(text: "WAITING", font: Font(name: "AppleSDGothicNeo-Bold", size: 120)!)!
    var isMaster = false
    var isControlled = false
    let expirationTimeSecs = 3.0
    var closestBeacon: CLBeacon? = nil
    var trackedBeacons: Dictionary<String, CLBeacon>?
    var trackedBeaconTimes: Dictionary<String, NSDate>?
    var textF = UITextField()
    var textString = ""
    

    override func setup() {
        label.center = Point(canvas.center.x + dx, canvas.center.y)
        createBeaconRegion()
        canvas.add(label)
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        trackedBeacons = Dictionary<String, CLBeacon>()
        trackedBeaconTimes = Dictionary<String, NSDate>()
        self.textF.delegate = self
        self.view.add(textF)
        
        textF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        canvas.addTapGestureRecognizer { _, center, _ in
            self.send(type: .master)
        }
    }

    func localize(point: Point) -> Point {
        return Point(point.x - dx, point.y)
    }
    
    func textFieldDidChange(_ textField: UITextField){
        print("Here")
        send(type: .message)
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        //print("Packet received " + String(describing: packet))
        let deviceId = SocketManager.sharedManager.deviceID
        switch packet.packetType {
        case PacketType.master:
            print("Master Packet Received")
            if(deviceId == packet.id){
                master()
                isMaster = true
                isControlled = false
                startScanning()
                textF.becomeFirstResponder()
            }
            else{
                slave()
                if(isMaster){
                    stopScanning()
                    textF.resignFirstResponder()
                }
                isMaster = false
            }
        case PacketType.distance:
            if(deviceId == packet.id && !isMaster){
                slaveClose()
                isControlled = true
            }
            else if(!isMaster){
                slave()
                isControlled = false
            }
        case PacketType.message:
            if(isControlled && !isMaster){
                let payload = packet.payload
                if payload != nil{
                    textString = String(data: payload!, encoding: .utf8)!
                    let anim = ViewAnimation(duration: 0.1) {
                        let center = self.label.center
                        self.label.text = self.textString
                        self.label.center = center
                    }
                    anim.curve = .EaseOut
                    anim.animate()
                }
            }
        default:
            break
        }
    }
    
    //This is how you send a packet, with no data
    func send(type: PacketType, id: Int = 0) {
        let deviceId: Int
        let packet: Packet
        var data: Data? = nil
        switch type {
        case PacketType.master:
            deviceId = SocketManager.sharedManager.deviceID
            print("Master packet sent")
        case PacketType.distance:
            deviceId = id
            //print("Distance packet sent")
        case PacketType.message:
            deviceId = SocketManager.sharedManager.deviceID
            data = textF.text?.data(using: .utf8)
        default:
            deviceId = SocketManager.sharedManager.deviceID
        }
        if data != nil {
            packet = Packet(type: type, id: deviceId, payload: data)
        }
        else {
            packet = Packet(type: type, id: deviceId)
        }
        socketManager.broadcastPacket(packet)
    }

    //Create your own functions to run
    func master() {
        let anim = ViewAnimation(duration: 0.25) {
            let center = self.label.center
            self.label.text = "MASTER"
            self.label.center = center
            self.label.fillColor = C4Grey
            self.canvas.backgroundColor = C4Blue
        }
        anim.curve = .EaseOut
        anim.animate()
    }

    func slave() {
        let anim = ViewAnimation(duration: 0.25) {
            let center = self.label.center
            self.label.text = self.textString
            self.label.center = center
            self.label.fillColor = C4Pink
            self.canvas.backgroundColor = C4Grey
        }
        anim.curve = .EaseOut
        anim.animate()
    }
    
    func slaveClose() {
        let anim = ViewAnimation(duration: 0.25) {
            let center = self.label.center
            self.label.text = self.textString
            self.label.center = center
            self.label.fillColor = C4Blue
            self.canvas.backgroundColor = C4Pink
        }
        anim.curve = .EaseOut
        anim.animate()
    }
    
    func createBeaconRegion(){
        let proximityUUID = UUID(uuidString:
            "40F9B7B7-60E4-40B0-858B-6A143B88DB81")
        let major : CLBeaconMajorValue = 100
        let minor : CLBeaconMinorValue = CLBeaconMinorValue(UIDevice.current.name.components(
            separatedBy: NSCharacterSet
                .decimalDigits
                .inverted)
            .joined(separator: ""))!
        let beaconID = UIDevice.current.name
        
        region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                major: major, minor: minor, identifier: beaconID)
        peripheralData = region.peripheralData(withMeasuredPower: nil)
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func advertiseDevice(region : CLBeaconRegion) {
        peripheral!.startAdvertising((peripheralData as! [String : Any]))
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case CBManagerState.poweredOn:
            advertiseDevice(region: region!)
            break
        default:
            break
            
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("error" + (error?.localizedDescription)!)
        }
        else {
            print("Device is advertising")
        }
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("dict \(dict)")
    }
    
    func startScanning() {
        let proximityUUID = UUID(uuidString:
            "40F9B7B7-60E4-40B0-858B-6A143B88DB81")!
        let ignore = CLBeaconMinorValue(UIDevice.current.name.components(
            separatedBy: NSCharacterSet
                .decimalDigits
                .inverted)
            .joined(separator: ""))
        for i: CLBeaconMinorValue in 1...28{
            if i != ignore{
                let name = "MO" + String(describing: i)
                let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, major: 100, minor: i, identifier: name)
                locManager.startMonitoring(for: beaconRegion)
                locManager.startRangingBeacons(in: beaconRegion)
            }
        }
        print("Monitoring devices")
    }
    
    func stopScanning() {
        let proximityUUID = UUID(uuidString:
            "40F9B7B7-60E4-40B0-858B-6A143B88DB81")!
        let ignore = CLBeaconMinorValue(UIDevice.current.name.components(
            separatedBy: NSCharacterSet
                .decimalDigits
                .inverted)
            .joined(separator: ""))
        for i: CLBeaconMinorValue in 1...28{
            if i != ignore{
                let name = "MO" + String(describing: i)
                let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, major: 100, minor: i, identifier: name)
                locManager.stopMonitoring(for: beaconRegion)
                locManager.stopRangingBeacons(in: beaconRegion)
            }
        }
        print("Stopped monitoring devices")
    }
    /*
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            print("Beacons Ranged")
            let nearestBeacon = beacons.first!
            let minor = Int(nearestBeacon.minor)
            send(type: .distance, id: minor)
        }
        else{
            print("No beacons in range")
        }
    }
    */
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let now = NSDate()
        for beacon in beacons {
            let key = keyForBeacon(beacon: beacon)
            if beacon.accuracy < 0 {
                NSLog("Ignoring beacon with negative distance")
            }
            else {
                trackedBeacons![key] = beacon
                if (trackedBeaconTimes![key] != nil) {
                    trackedBeaconTimes![key] = now
                }
                else {
                    trackedBeaconTimes![key] = now
                }
            }
        }
        purgeExpiredBeacons()
        calculateClosestBeacon()
        let minor = closestBeacon?.minor as? Int
        if (minor != nil) {
            send(type: .distance, id: minor!)
        }
        
    }
    
    func calculateClosestBeacon() {
        var changed = false
        // Initialize cloestBeaconCandidate to the latest tracked instance of current closest beacon
        var closestBeaconCandidate: CLBeacon?
        if closestBeacon != nil {
            let closestBeaconKey = keyForBeacon(beacon: closestBeacon!)
            for key in (trackedBeacons?.keys)! {
                if key == closestBeaconKey {
                    closestBeaconCandidate = trackedBeacons?[key]
                }
            }
        }
        
        for key in (trackedBeacons?.keys)! {
            var closer = false
            let beacon = trackedBeacons![key]
            if (beacon != closestBeaconCandidate) {
                if beacon!.accuracy > 0 {
                    if closestBeaconCandidate == nil {
                        closer = true
                    }
                    else if beacon!.accuracy < closestBeaconCandidate!.accuracy {
                        closer = true
                    }
                }
                if closer {
                    closestBeaconCandidate = beacon
                    changed = true
                }
            }
        }
        if (changed) {
            closestBeacon = closestBeaconCandidate
        }
    }
    
    func keyForBeacon(beacon: CLBeacon) -> String {
        return "\(beacon.minor)"
    }
    
    func purgeExpiredBeacons() {
        let now = NSDate()
        var changed = false
        var newTrackedBeacons = Dictionary<String, CLBeacon>()
        var newTrackedBeaconTimes = Dictionary<String, NSDate>()
        for key in (trackedBeacons?.keys)! {
            let beacon = trackedBeacons![key]
            let lastSeenTime = trackedBeaconTimes![key]!
            if now.timeIntervalSince(lastSeenTime as Date) > expirationTimeSecs {
                NSLog("******* Expired seeing beacon: \(key) time interval is \(now.timeIntervalSince(lastSeenTime as Date))")
                changed = true
            }
            else {
                newTrackedBeacons[key] = beacon!
                newTrackedBeaconTimes[key] = lastSeenTime
            }
        }
        if changed {
            trackedBeacons = newTrackedBeacons
            trackedBeaconTimes = newTrackedBeaconTimes
        }
    }
}
