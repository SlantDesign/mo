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
    func shouldPlay() {}
    func shouldPause() {}
    func shouldStop() {}
    func shouldReset() {}
}
