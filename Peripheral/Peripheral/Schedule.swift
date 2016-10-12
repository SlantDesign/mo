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

var dataLoaded: Int = 0
let hour: (width: CGFloat, height: CGFloat) = (997.0/2.0, 155.0)

class Schedule: NSObject, UICollectionViewDataSource {
//    private static var __once: () = {
//        self.setStartEndDates()
//        self.loadData()
//    }()
    var venueOrder: [String : [String]]!
    var dayOffsets: [String : TimeInterval]!

    static let shared = Schedule()
    var startDate: Date!
    var endDate: Date!
    var totalInterval: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }

    var totalWidth: CGFloat {
        return 2 * CGFloat(totalInterval) / 3600.0 * hour.width
    }

    var singleContentWidth: CGFloat {
        return CGFloat(totalInterval) / 3600.0 * hour.width
    }

    var syncTimestamp: TimeInterval = 0
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
//        _ = Schedule.__once
        self.setStartEndDates()
        self.loadData()
    }

    func setStartEndDates() {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "GMT")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        startDate = df.date(from: "2016-04-11 13:00:00")
        endDate = df.date(from: "2016-04-17 12:00:00")

        guard startDate != nil && endDate != nil else {
            print("Couldn't create the start and end dates")
            exit(0)
        }
    }

    func loadData() {        
        let path = Bundle.main.path(forResource: "programme2016", ofType: "plist")!
        guard let e = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
            print("Could not extract array of events from file")
            return
        }

        let venueOrderPath = Bundle.main.path(forResource: "venueOrder", ofType: "plist")
        guard let order = NSDictionary(contentsOfFile: venueOrderPath!) as? [String : [String]] else {
            print("Could not extract array of events from file")
            return
        }
        venueOrder = order

        for var event in e {
            let date = event["date"] as! Date
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

        events.sort {
            $0 < $1
        }

        ShapeLayer.disableActions = true
        for event in events {
            let frame = frameFor(event)
            let color = colorFor(event)
            animatablePaths.append(AnimatableCellPath(frame: frame, event: event, color: color))
        }
    }

    func indexesOfEventsBetween(_ start: Date, end: Date) -> [Int] {
        var indexes = [Int]()
        for (index, event) in events.enumerated() {
            //if the event date occurs before the visible end date
            //and if the event endDate occurs after the visible start date
            let eventStart = event.date
            let eventEnd = event.endDate
            let a = (eventStart as NSDate).earlierDate(end) == eventStart
            let b = (start as NSDate).laterDate(eventEnd as Date) == eventEnd
            if a && b {
                indexes.append(index)
            }
        }
        return indexes
    }

    func eventAt(_ indexPath: IndexPath) -> Event {
        return events[(indexPath as NSIndexPath).item]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.syncTimestamp = syncTimestamp
        cell.animatablePath = animatablePaths[(indexPath as NSIndexPath).item]
        return cell
    }

    func frameFor(_ event:Event) -> CGRect {
        let x = CGFloat(event.date.timeIntervalSince(startDate)) / 3600.0 * hour.width
        let h = event.type == "OverNight" ? 980 : heightForDay(event.day)
        let y = event.type == "OverNight" ? 0 : CGFloat(levelForVenue(event.location, day: event.day)) * h
        let w = CGFloat(event.duration) / 60.0 * hour.width
        let base = CGRect(x: x, y: y, width: w, height: h)
        return base.insetBy(dx: 2, dy: 6)
    }

    func colorFor(_ event: Event) -> CGColor {
        switch event.type {
        case "Performance":
            return UIColor(red: 0.176, green: 1.0, blue: 0.89, alpha: 1.0).cgColor
        case "Workshop":
            return UIColor(red: 0.243, green: 0.831, blue: 1.0, alpha: 1.0).cgColor
        case "Lecture":
            return UIColor(red: 0.427, green: 0.522, blue: 1.0, alpha: 1.0).cgColor
        case "Screening":
            return UIColor(red: 0.176, green: 0.945, blue: 1.0, alpha: 1.0).cgColor
        case "IntensiveWorkshop":
            return UIColor(red: 0.369, green: 0.627, blue: 1.0, alpha: 1.0).cgColor
        case "QA":
            return UIColor(red: 0.467, green: 0.392, blue: 1.0, alpha: 1.0).cgColor
        case "Panel":
            return UIColor(red: 0.298, green: 0.725, blue: 1.0, alpha: 1.0).cgColor
        case "Venue":
            return UIColor(red: 0.635, green: 0.392, blue: 1.0, alpha: 1.0).cgColor
        case "OverNight":
            return UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0).cgColor
        default:
            return UIColor.lightGray.cgColor
        }
    }
    func levelForVenue(_ venue: String, day: String) -> Int {
        return venueOrder[day]!.index(of: venue)!
    }

    func heightForDay(_ day: String) -> CGFloat {
        guard let order = venueOrder else {
            print("venueOrder not initialized")
            return 1.0
        }
        let dayCount = Double(order[day]!.count)
        let calculatedHeight = 980.0 / dayCount
        return CGFloat(min(calculatedHeight, 245))
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HourHeaderView", for: indexPath)

        if let hour = headerView as? HourHeaderView {
            hour.label!.text = String(format:"%2d:00", ((indexPath as NSIndexPath).item + 6) % 24)
        }

        return headerView
    }

}
