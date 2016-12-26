// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import Foundation

struct Event: Equatable, Hashable, CustomStringConvertible {
    var date = Date() {
        didSet {

        }
    }
    var day = ""
    var endDate: Date {
        return date.addingTimeInterval(duration*60.0)
    }
    var duration = 0.0
    var location = "Belgrade"
    var title = "M/O"
    var artists = ["Travis Kirton, Jake Lim"]
    var summary = "M/O"
    var type = "Unknown"
    var function = ""

    var hashValue: Int {
        return "\(date)\(duration)\(location)\(title)".hashValue
    }

    var description: String {
        return "\(date)\n\(duration)\n\(endDate)\n\(location)\n\(title)\n"
    }
}

func == (lhs: Event, rhs: Event) -> Bool {
    let isEqual = lhs.date.compare(rhs.date) == .orderedSame
    return isEqual &&
        lhs.duration == rhs.duration &&
        lhs.location == lhs.location &&
        lhs.title == lhs.title
}

func > (lhs: Event, rhs: Event) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedDescending ? true : false
}

func < (lhs: Event, rhs: Event) -> Bool {
    return rhs > lhs
}
