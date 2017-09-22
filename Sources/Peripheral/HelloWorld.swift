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

class HelloWorld: UniverseController, GCDAsyncSocketDelegate {
    let socketManager = SocketManager.sharedManager
    let sentLabel = TextShape(text: "Sent: 0", font: Font(name: "AppleSDGothicNeo-Bold", size: 25)!)!
    let recLabel = TextShape(text: "Received: 0", font: Font(name: "AppleSDGothicNeo-Bold", size: 25)!)!
    var dataID: UInt64 = 1
    var lastReceived: UInt64 = 0
    var numReceived: UInt64 = 0
    @IBOutlet var slider: UISlider!
    let sliderVal = TextShape(text: "0.1 sec/message", font: Font(name: "AppleSDGothicNeo-Bold", size: 30)!)!
    var selectedValue: Float = 0.1
    var histLine: HistoryLine!
    

    override func setup() {
        canvas.backgroundColor = black
        let height = canvas.frame.height
        let width = canvas.frame.width
        histLine = HistoryLine(width: Int(width-50))
        canvas.add(histLine)
        histLine.center = Point(canvas.center.x+dx, canvas.center.y)
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 3
        slider.setValue(1, animated: false)
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueChanged), for: UIControlEvents.valueChanged)
        canvas.add(slider)
        canvas.add(sliderVal)
        sliderVal.center = Point(canvas.center.x + dx, canvas.center.y + height/3)
        sliderVal.fillColor = white
        slider.frame = CGRect(origin: CGPoint(x: CGFloat(canvas.center.x+dx-(width-50)/2),y: CGFloat(height*5/6+30)), size: CGSize(width: width-50, height: 20))
        sendMessage()
        canvas.add(sentLabel)
        sentLabel.center = Point(canvas.center.x+dx, canvas.center.y-height/4-40)
        canvas.add(recLabel)
        recLabel.center = Point(canvas.center.x+dx, canvas.center.y-height/4)
        sentLabel.fillColor = white
        recLabel.fillColor = white
    }

    func localize(point: Point) -> Point {
        return Point(point.x - dx, point.y)
    }
    
    func sendMessage(){
        send()
        let center = self.sentLabel.center
        self.sentLabel.text = "Sent: " + String(dataID)
        self.sentLabel.center = center
        dataID += 1
        let sendTime = DispatchTime.now() + DispatchTimeInterval.microseconds(Int(selectedValue*1000000))
        DispatchQueue.main.asyncAfter(deadline: sendTime) {
            self.sendMessage()
        }
    }

    //This is how you receive and decipher a packet with no data
    override func receivePacket(_ packet: Packet) {
        let deviceId = SocketManager.sharedManager.deviceID
        if(deviceId == packet.id){
            numReceived += 1
            let payload = packet.payload
            let center = self.recLabel.center
            var id: UInt64 = 0
            (payload! as NSData).getBytes(&id)
            self.recLabel.text = "Received: " + String(numReceived)
            for _ in lastReceived..<(id-1){
                histLine.newPoint(length: 1, isGreen: false)
            }
            histLine.newPoint(length: 1, isGreen: true)
            lastReceived = id
            self.recLabel.center = center
        }
    }

    //This is how you send a packet, with no data
    func send() {
        let deviceId = SocketManager.sharedManager.deviceID
        let data = NSMutableData()
        data.append(&dataID, length: MemoryLayout<Int>.size)
        let packet = Packet(type: PacketType.hello, id: deviceId, payload: data as Data)
        socketManager.broadcastPacket(packet)
        
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        
        let center = self.sliderVal.center
        selectedValue = pow(10, -1*sender.value)
        selectedValue *= 10000
        selectedValue = round(selectedValue)
        selectedValue = selectedValue/10000
        self.sliderVal.text = String(stringInterpolationSegment: selectedValue) + " sec/message"
        self.sliderVal.center = center
    }
        
}
