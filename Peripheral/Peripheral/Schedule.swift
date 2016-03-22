//
//  Schedule.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import CocoaLumberjack
import Foundation
import UIKit

var dataLoaded: dispatch_once_t = 0
let hour: (width: NSTimeInterval, height: NSTimeInterval) = (384.0, 128.0)

class Schedule: NSObject, UICollectionViewDataSource {
    static let shared = Schedule()
    var startDate: NSDate!
    var endDate: NSDate!
    var totalInterval: NSTimeInterval {
        return endDate.timeIntervalSinceDate(startDate)
    }

    var totalWidth: CGFloat {
        return CGFloat(totalInterval / 3600.0 * hour.width)
    }
    var events = [Event]()

    override func awakeFromNib() {
        dispatch_once(&dataLoaded) {
            self.setStartEndDates()
            self.loadData()
            DDLogVerbose("Schedule Loaded (Awake)")
        }
    }
    
    override init() {
        super.init()
        dispatch_once(&dataLoaded) {
            self.setStartEndDates()
            self.loadData()
            DDLogVerbose("Schedule Loaded (Init)")
        }
    }

    func setStartEndDates() {
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(name: "GMT")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        startDate = df.dateFromString("2016-04-14 17:00:00")
        endDate = df.dateFromString("2016-04-17 06:00:00")

        guard startDate != nil && endDate != nil else {
            print("Couldn't create the start and end dates")
            exit(0)
        }
    }

    func loadData() {
        let path = NSBundle.mainBundle().pathForResource("events", ofType: "plist")!
        guard let e = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
            print("Could not extract array of events from file")
            return
        }

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
                        let event = Event(date: date, duration: duration, location: location, title: titleString)
                        events.append(event)
                    }
            }
        }
        events.sortInPlace {
            $0 < $1
        }
    }

    func indexPathsOfEventsBetween(start: NSDate, end: NSDate) -> [NSIndexPath] {
        var paths = [NSIndexPath]()
        for (index, event) in events.enumerate() {
            //if the event date occurs before the visible end date
            //and if the event endDate occurs after the visible start date
            let eventStart = event.date
            let eventEnd = event.endDate
            let a = eventStart.earlierDate(end) === eventStart
            let b = start.laterDate(eventEnd) === eventEnd
            if a && b {
                paths.append(NSIndexPath(forItem: index, inSection: 0))
            }
        }
        return paths
    }

    func eventAt(indexPath: NSIndexPath) -> Event {
        return events[indexPath.item]
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        let event = events[indexPath.item]
        cell.frame = frameFor(event)
        cell.event = event
        return cell
    }

    //fix displacement errors...

    func frameFor(event:Event) -> CGRect {

        let x = CGFloat(event.date.timeIntervalSinceDate(startDate) / 3600.0 * hour.width)
        let y = CGFloat(NSTimeInterval(event.location.level) * hour.height)
        let w = CGFloat(event.duration / 60.0 * hour.width)
        let h = CGFloat(hour.height)
        return CGRect(x: x, y: y, width: w, height: h)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
}