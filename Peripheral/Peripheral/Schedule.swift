//
//  Schedule.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation

class Schedule {
    let hours = 24
    let days = 7
    var events = [Event]()
    var startDate: NSDate!

    init() {
        let path = NSBundle.mainBundle().pathForResource("events", ofType: "plist")!
        guard let e = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
            print("Could not extract array of events from file")
            return
        }

        let opening = e[0]
        startDate = opening["date"] as? NSDate

        var unsortedEvents = Set<Event>()
        for event in e {
            if let date = event["date"] as? NSDate,
                let artists = event["artists"] as? [String],
                let duration = event["duration"] as? Double,
                let title = event["title"] as? String,
                let location = event["location"] as? String {
                    var titleString = "M/O"
                    if artists.count > 0 {
                        titleString = artists[0]
                        for i in 1..<artists.count {
                            titleString += ", \(artists[i])"
                        }
                    } else if title != "" {
                        titleString = title
                    }

                    if let location = Location(rawValue: location) {
                        unsortedEvents.insert(Event(date: date, duration: duration, location: location, title: titleString))
                    }

                    if unsortedEvents.count > 4 {
                        break
                    }
            }
        }
        events = unsortedEvents.sort({$0 < $1})
    }
}