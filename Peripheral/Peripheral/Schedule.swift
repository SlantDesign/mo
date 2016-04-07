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
import C4

var dataLoaded: dispatch_once_t = 0
let hour: (width: CGFloat, height: CGFloat) = (997.0/2.0, 155.0)

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
        return 2 * CGFloat(totalInterval) / 3600.0 * hour.width
    }

    var singleContentWidth: CGFloat {
        return CGFloat(totalInterval) / 3600.0 * hour.width
    }

    var events = [Event]()

    var animatablePaths = [AnimatableCellPath]()

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
        let path = NSBundle.mainBundle().pathForResource("programme2016", ofType: "plist")!
        guard let e = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
            print("Could not extract array of events from file")
            return
        }

        let venueOrderPath = NSBundle.mainBundle().pathForResource("venueOrder", ofType: "plist")
        guard let order = NSDictionary(contentsOfFile: venueOrderPath!) as? [String : [String]] else {
            print("Could not extract array of events from file")
            return
        }
        venueOrder = order

        for var event in e {
            let date = event["date"] as! NSDate
            let day = event["day"] as! String
            let artists = event["artists"] as! [String]
            let duration = event["duration"] as! Double
            let title = event["title"] as! String
            let location = event["location"] as! String
            let summary = event["description"] as! String
            let type = event["type"] as! String
            let function = event["function"] as! String
            let event = Event(date: date, day: day, duration: duration, location: location, title: title, artists: artists, summary: summary, type: type, function: function)
            events.append(event)
        }

        events.sortInPlace {
            $0 < $1
        }

        ShapeLayer.disableActions = true
        for event in events {
            let frame = frameFor(event)
            let color = colorFor(event)
            animatablePaths.append(AnimatableCellPath(frame: frame, event: event, color: color))
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
        cell.animatablePath = animatablePaths[indexPath.item]
        return cell
    }

    func frameFor(event:Event) -> CGRect {
        let x = CGFloat(event.date.timeIntervalSinceDate(startDate)) / 3600.0 * hour.width
        let h = heightForDay(event.day)
        let y = CGFloat(levelForVenue(event.location, day: event.day)) * h
        let w = CGFloat(event.duration) / 60.0 * hour.width
        return CGRect(x: x, y: y, width: w, height: h)
    }

    func colorFor(event: Event) -> CGColor {
        switch event.type {
        case "IntensiveWorkshop":
            return UIColor.blueColor().CGColor
        case "Workshop":
            return UIColor.redColor().CGColor
        case "Screening":
            return UIColor.greenColor().CGColor
        case "Lecture":
            return UIColor.darkGrayColor().CGColor
        case "Performance":
            return UIColor.purpleColor().CGColor
        case "QA":
            return UIColor.magentaColor().CGColor
        case "Panel":
            return UIColor.orangeColor().CGColor
        case "Venue":
            return UIColor.yellowColor().CGColor
        case "OverNight":
            return UIColor.whiteColor().CGColor
        default:
            return UIColor.lightGrayColor().CGColor
        }
    }
    func levelForVenue(venue: String, day: String) -> Int {
        return venueOrder[day]!.indexOf(venue)!
    }

    func heightForDay(day: String) -> CGFloat {
        guard let order = venueOrder else {
            print("venueOrder not initialized")
            return 1.0
        }
        let dayCount = Double(order[day]!.count)
        let calculatedHeight = 980.0 / dayCount
        return CGFloat(min(calculatedHeight, 245))
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HourHeaderView", forIndexPath: indexPath)

        if let hour = headerView as? HourHeaderView {
            hour.label!.text = String(format:"%2d:00", (indexPath.item + 10) % 24)
        }

        return headerView
    }

}