//
//  AppDelegate.swift
//  Master
//
//  Created by travis on 2016-03-14.
//  Copyright © 2016 C4. All rights reserved.
//

import Cocoa
import CocoaLumberjack

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var socketManager: SocketManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DDLog.add(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance()) // ASL = Apple System Logs

        socketManager = SocketManager.sharedManager
    }
}

