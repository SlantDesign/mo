//
//  Video.swift
//  MO
//
//  Created by travis on 2017-01-02.
//  Copyright © 2017 Slant. All rights reserved.
//

import C4
import CocoaAsyncSocket
import CocoaLumberjack
import MO
import UIKit

extension PacketType {
    static let play = PacketType(rawValue: 20)
    static let pause = PacketType(rawValue: 21)
    static let stop = PacketType(rawValue: 22)
    static let reset = PacketType(rawValue: 23)
}

public protocol VideoUniverseDelegate: class {
    func shouldPlay()
    func shouldPause()
    func shouldStop()
    func shouldReset()
}

class Video: UniverseController, GCDAsyncSocketDelegate, VideoUniverseDelegate {
    let socketManager = SocketManager.sharedManager
    var movie: Movie?

    override func setup() {
        movie?.origin = canvas.bounds.origin
        movie?.width = canvas.width
        movie?.loops = true
        canvas.add(movie)
        canvas.sendToBack(movie)
        createInterface()
    }

    func createInterface() {
        guard let playButton = createButton(title: "PLAY", packetMessage: .play) else {
            print("Could not create \(title) buttton")
            return
        }

        playButton.origin = Point(dx + 100, canvas.height - 100)
        canvas.add(playButton)

        guard let stopButton = createButton(title: "STOP", packetMessage: .stop) else {
            print("Could not create \(title) buttton")
            return
        }

        stopButton.origin = Point(dx + 350, canvas.height - 100)
        canvas.add(stopButton)
    }

    func createButton(title: String, packetMessage: PacketType) -> View? {
        let f = Font(name: "AppleSDGothicNeo-Bold", size: 80)!
        guard let title = TextShape(text: title, font: f) else {
            print("Could not create button title")
            return nil
        }

        title.interactionEnabled = false

        var frame = title.frame
        frame.size.width += 20
        frame.size.height += 20

        let button = Rectangle(frame: frame)
        button.fillColor = white.colorWithAlpha(0.33)

        title.origin.x += 10
        title.origin.y += 10
        button.add(title)

        button.addTapGestureRecognizer { _, _, _ in
            self.send(videoControlPacket: packetMessage)
        }

        return button
    }

    func send(videoControlPacket: PacketType) {
        let deviceId = SocketManager.sharedManager.deviceID
        let packet = Packet(type: videoControlPacket, id: deviceId)
        self.socketManager.broadcastPacket(packet)
    }

    override func receivePacket(_ packet: Packet) {
        switch packet.packetType {
        case PacketType.play:
            self.shouldPlay()
            break
        case PacketType.stop:
            self.shouldStop()
            break
        default:
            break
        }
    }

    override func load() {
        let id = SocketManager.sharedManager.deviceID
        let videoName = "UBC-Video-Boat-MO\(id).mov"
        movie = Movie(videoName)
    }

    override func unload() {
        movie?.stop()
        canvas.remove(movie)
        movie = nil
    }

    func shouldPlay() {
        movie?.play()
    }

    func shouldPause() {
        movie?.pause()
    }

    func shouldStop() {
        movie?.stop()
    }

    func shouldReset() {

    }
}
