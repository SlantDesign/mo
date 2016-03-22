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
    var duration = 0.0
    var location = Location.Unknown
    var title = ""

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

enum Location: String {
    case Kinoteka1 = "Kinoteka1"
    case KinotekaGround = "KinotekaGround"
    case KinotekaPool = "KinotekaPool"
    case KinotekaLibrary = "KinotekaLibrary"
    case Kinoteka200 = "Kinoteka200"
    case KinotekaCinema = "KinotekaCinema"
    case KolaracS = "KolaracS"
    case KolaracMainHall = "KolaracMainHall"
    case DomOmladineBeograda = "DomOmladineBeograda"
    case Unknown = "Unknown"

    var level: Int {
        switch self {
        case .KinotekaPool:
            return 0
        case .KolaracS:
            return 1
        case .Kinoteka200:
            return 2
        case .KinotekaCinema:
            return 3
        case .KolaracMainHall:
            return 4
        default:
            return -1
        }
    }
}
