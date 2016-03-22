//
//  Schedule.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation
import UIKit

var dataLoaded: dispatch_once_t = 0

class Schedule: NSObject, UICollectionViewDataSource {
    let hours = 24
    let days = 7
    var events = [Event]()
    var startDate: NSDate!

    override func awakeFromNib() {
        dispatch_once(&dataLoaded) {
            self.loadData()
        }
    }

    override init() {
        super.init()
        dispatch_once(&dataLoaded) {
            self.loadData()
        }
    }

    func loadData() {
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

    func indexPathsOfEventsBetween(start t1: NSTimeInterval, end t2: NSTimeInterval) -> [NSIndexPath] {
        var paths = [NSIndexPath]()
        let start = startDate.dateByAddingTimeInterval(t1)
        let end = startDate.dateByAddingTimeInterval(t2)
        for (index, event) in events.enumerate() {
            //if the startDate occurs before the last visible date
            //and if the end date occurs after the first visible date
            if event.date.earlierDate(end) === event.date &&
                event.endDate.laterDate(start) == event.endDate {
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
        cell.event = events[indexPath.item]
        return cell
        
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
}