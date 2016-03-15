//
//  AppDelegate.swift
//  Master
//
//  Created by travis on 2016-03-14.
//  Copyright © 2016 C4. All rights reserved.
//

import Cocoa
import CocoaLumberjackSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var socketManager: SocketManager?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if NSUserDefaults.standardUserDefaults().objectForKey("deviceID") == nil {
            NSUserDefaults.standardUserDefaults().setInteger(Int(INT_MAX), forKey: "deviceID")
        }

        DDLog.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs

        socketManager = SocketManager.sharedManager
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        socketManager?.disconnectAll()
    }
}

