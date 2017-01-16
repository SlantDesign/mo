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

class Video: UniverseController, GCDAsyncSocketDelegate, VideoUniverseDelegate, PlayPauseButtonDelegate {
    let playPause = PlayPauseButton()
    let socketManager = SocketManager.sharedManager
    var movie: Movie?

    override func setup() {
        movie?.origin = canvas.bounds.origin
        movie?.width = canvas.width
        movie?.loops = true
        canvas.add(movie)
        canvas.sendToBack(movie)

        playPause.playPauseDelegate = self
        playPause.center = Point(canvas.center.x + dx, canvas.height - playPause.height)
        canvas.add(playPause)
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
        case PacketType.pause:
            self.shouldStop()
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
        playPause.animateToPause()
    }

    func shouldPause() {
        movie?.pause()
        playPause.animateToPlay()
    }

    func shouldStop() {
        movie?.stop()
        playPause.animateToPlay()
    }

    func shouldReset() {

    }

    func sendPause() {
        self.send(videoControlPacket: .pause)
    }

    func sendPlay() {
        self.send(videoControlPacket: .play)
    }
}


