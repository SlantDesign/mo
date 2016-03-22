//
//  Helpers.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation

struct Event: Equatable, Hashable {
    var date = NSDate()
    var endDate: NSDate {
        return date.dateByAddingTimeInterval(duration*60.0)
    }
    var duration = 0.0
    var location = Location.Unknown
    var title = "M/O"

    var hashValue: Int {
        return "\(date)\(duration)\(location)\(title)".hashValue
    }
}

func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.date.isEqualToDate(rhs.date) &&
    lhs.duration == rhs.duration &&
    lhs.location == lhs.location &&
    lhs.title == lhs.title
}

func >(lhs: Event, rhs: Event) -> Bool {
    return lhs.date.laterDate(rhs.date) === lhs.date ? true : false
}

func <(lhs: Event, rhs: Event) -> Bool {
    return rhs > lhs
}