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
let hour: (width: NSTimeInterval, height: NSTimeInterval) = (997.0/2.0, 155.0)

class Schedule: NSObject, UICollectionViewDataSource {
    var venueOrder: [String : [String]]!
    var dayOffsets: [String : NSTimeInterval]!

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
        setup()
    }

    override init() {
        super.init()
        setup()
    }

    func setup() {
        dispatch_once(&dataLoaded) {
            self.setStartEndDates()
            self.loadData()
        }
    }

    func setStartEndDates() {
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(name: "GMT")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        startDate = df.dateFromString("2016-04-11 17:00:00")
        endDate = df.dateFromString("2016-04-17 11:00:00")

        guard startDate != nil && endDate != nil else {
            print("Couldn't create the start and end dates")
            exit(0)
        }
    }

    func loadData() {
        let dayOffsetPath = NSBundle.mainBundle().pathForResource("dayOffsets", ofType: "plist")
        guard let offsets = NSDictionary(contentsOfFile: dayOffsetPath!) as? [String : NSNumber] else {
            print("Could not extract day offsets.")
            return
        }

        dayOffsets = [String : NSTimeInterval]()
        for key in offsets.keys {
            dayOffsets[key] = NSTimeInterval(offsets[key]!.doubleValue)
        }
        
        let path = NSBundle.mainBundle().pathForResource("programme2016", ofType: "plist")!
        guard let e = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
            print("Could not extract array of events from file")
            return
        }

        for var event in e {
            var date = event["date"] as! NSDate
            let day = event["day"] as! String
            date = offsetDate(date, currentDay: day)
            let artists = event["artists"] as! [String]
            let duration = event["duration"] as! Double
            let title = event["title"] as! String
            let location = event["location"] as! String
            let summary = event["description"] as! String
            let type = event["type"] as! String
            let event = Event(date: date, day: day, duration: duration, location: location, title: title, artists: artists, summary: summary, type: type)
            events.append(event)
        }
        events.sortInPlace {
            $0 < $1
        }

        let venueOrderPath = NSBundle.mainBundle().pathForResource("venueOrder", ofType: "plist")
        guard let order = NSDictionary(contentsOfFile: venueOrderPath!) as? [String : [String]] else {
            print("Could not extract array of events from file")
            return
        }
        venueOrder = order
    }

    func offsetDate(date: NSDate, currentDay: String) -> NSDate {
        var offset: NSTimeInterval = 0
        switch currentDay {
        case "Tuesday", "TuesdayNight":
            offset = dayOffsets["Tuesday"]!
        case "Wednesday", "WednesdayNight":
            offset = dayOffsets["Wednesday"]!
        case "Thursday", "ThursdayNight":
            offset = dayOffsets["Thursday"]!
        case "Friday", "FridayNight":
            offset = dayOffsets["Friday"]!
        case "Saturday", "SaturdayNight":
            offset = dayOffsets["Saturday"]!
        default:
            break
        }

        return NSDate(timeInterval: -offset, sinceDate: date)
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

    /*to do:
     - colors (by type)
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        let event = events[indexPath.item]
        cell.frame = frameFor(event)
        cell.event = event
        let mod = cell.frame.origin.y / 1024.0
        cell.animate()
        return cell
    }

    func frameFor(event:Event) -> CGRect {
//        var offset: NSTimeInterval = 0.0
//        if event.day == "Tuesday" {
//            offset = 54000.0
//        }
        let x = CGFloat((event.date.timeIntervalSinceDate(startDate)) / 3600.0 * hour.width)
        let h = heightForDay(event.day)
        let y = CGFloat(levelForVenue(event.location, day: event.day)) * h
        let w = CGFloat(event.duration / 60.0 * hour.width)
        return CGRect(x: x, y: y, width: w, height: h)
    }

    func levelForVenue(venue: String, day: String) -> Int {
        return venueOrder[day]!.indexOf(venue)!
    }

    func heightForDay(day: String) -> CGFloat {
        guard let order = venueOrder else {
            print("venueOrder not initialize")
            return 1.0
        }
        let dayCount = Double(order[day]!.count)
        let calculatedHeight = 1024.0 / dayCount
        return CGFloat(min(calculatedHeight, 256.0))
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
}