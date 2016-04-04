//
//  Location.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation

enum Day: Int {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Unknown

    init(date: NSDate) {
        let startDate = Schedule.shared.startDate
        let interval = date.timeIntervalSinceDate(startDate)
        let secondsInDay = NSTimeInterval(24 * 60 * 60)
        let secondsInFirstDay = NSTimeInterval(14 * 60 * 60)

        switch interval {
        case 0.0..<secondsInFirstDay:
            self = .Monday
        case secondsInFirstDay..<(secondsInFirstDay + secondsInDay):
            self = .Tuesday
        case (secondsInFirstDay + secondsInDay)..<(secondsInFirstDay + secondsInDay * 2.0):
            self = .Wednesday
        case (secondsInFirstDay + secondsInDay * 2.0)..<(secondsInFirstDay + secondsInDay * 3.0):
            self = .Thursday
        case (secondsInFirstDay + secondsInDay * 3.0)..<(secondsInFirstDay + secondsInDay * 4.0):
            self = .Friday
        case (secondsInFirstDay + secondsInDay * 4.0)..<(secondsInFirstDay + secondsInDay * 5.0):
            self = .Saturday
        default:
            self = .Unknown
            assertionFailure("Unknown day.")
        }
    }
}

enum Location: String {
    case UKParobrod0 = "UKParobrod0"
    case UKParobrod1 = "UKParobrod1"
    case UKParobrod2 = "UKParobrod2"
    case UKParobrod3 = "UKParobrod3"
    case KolaracMain = "KolaracMain"
    case KinotekaCinema = "KinotekaCinema"
    case Kinoteka200 = "Kinoteka200"
    case Kinoteka = "Kinoteka"
    case Kinoteka0 = "Kinoteka0"
    case Kinoteka1 = "Kinoteka1"
    case Kinoteka2 = "Kinoteka2"
    case Kinoteka3 = "Kinoteka3"
    case Kinoteka4 = "Kinoteka4"
    case Kinoteka5 = "Kinoteka5"
    case Kinoteka6 = "Kinoteka6"
    case Kinoteka7 = "Kinoteka7"
    case GalleryZvono = "GalleryZvono"
    case KinotekaPool = "KinotekaPool"
    case Magacin = "Magacin"
    case Unknown = "Unknown"
}

enum LocationMonday: String {
    case UKParobrod0 = "UKParobrod0"
    case UKParobrod1 = "UKParobrod1"
    case UKParobrod2 = "UKParobrod2"
    case UKParobrod3 = "UKParobrod3"
}

enum LocationTuesday: String {
    case UKParobrod0 = "UKParobrod0"
    case UKParobrod1 = "UKParobrod1"
    case UKParobrod2 = "UKParobrod2"
    case UKParobrod3 = "UKParobrod3"
    case KinotekaCinema = "KinotekaCinema"
    case Kinoteka200 = "Kinoteka200"
    case Kinoteka = "Kinoteka"
    case DomOmladine = "DomOmladine"
    case Twenty44 = "Twenty44"
    case GalleryZvono = "GalleryZvono"
    case KCGrad = "KCGrad"

    var level: Int {
        switch self {
        case .UKParobrod0:
            return 0
        case .UKParobrod1:
            return 1
        case .UKParobrod2:
            return 2
        case .UKParobrod3:
            return 3
        case .KinotekaCinema:
            return 4
        case .Kinoteka200:
            return 5
        case .Kinoteka:
            return 6
        case .DomOmladine:
            return 7
        case .Twenty44:
            return 8
        case .GalleryZvono:
            return 9
        case.KCGrad:
            return 10
        }
    }
}

enum LocationTuesdayNight: String {
    case DOT = "DOT"

    var level: Int {
        return 0
    }
}

enum LocationWednesday: String {
    case UKParobrod0 = "UKParobrod0"
    case UKParobrod1 = "UKParobrod1"
    case UKParobrod2 = "UKParobrod2"
    case UKParobrod3 = "UKParobrod3"
    case KinotekaCinema = "KinotekaCinema"
    case Kinoteka200 = "Kinoteka200"

    var level: Int {
        switch self {
        case .UKParobrod0:
            return 0
        case .UKParobrod1:
            return 1
        case .UKParobrod2:
            return 2
        case .UKParobrod3:
            return 3
        case .KinotekaCinema:
            return 4
        case .Kinoteka200:
            return 5
        }
    }
}

enum LocationWednesdayNight: String {
    case DomOmladine = "DomOmladine"
    case Twenty44 = "Twenty44"
    case GalleryZvono = "GalleryZvono"
    case KCGrad = "KCGrad"

    var level: Int {
        switch self {
        case .KCGrad:
            return 0
        case .GalleryZvono:
            return 1
        case .DomOmladine:
            return 2
        case .Twenty44:
            return 3
        }
    }
}

enum LocationThursday: String {
    case KolaracMain = "KolaracMain"
    case KinotekaCinema = "KinotekaCinema"
    case GalleryZvono = "GalleryZvono"
    case Kinoteka0 = "Kinoteka0"
    case Kinoteka1 = "Kinoteka1"
    case Kinoteka2 = "Kinoteka2"
    case Kinoteka3 = "Kinoteka3"
    case Kinoteka4 = "Kinoteka4"
    case Kinoteka5 = "Kinoteka5"
    case Kinoteka6 = "Kinoteka6"
    case Kinoteka7 = "Kinoteka7"

    var level: Int {
        switch self {
        case .KolaracMain:
            return 0
        case .KinotekaCinema:
            return 1
        case .GalleryZvono:
            return 2
        case .Kinoteka0:
            return 3
        case .Kinoteka1:
            return 4
        case .Kinoteka2:
            return 5
        case .Kinoteka3:
            return 6
        case .Kinoteka4:
            return 7
        case .Kinoteka5:
            return 8
        case .Kinoteka6:
            return 9
        case .Kinoteka7:
            return 10
        }
    }
}

enum LocationThursdayNight: String {
    case Magacin = "Magacin"

    var level: Int {
        return 0
    }
}

enum LocationFriday: String {
    case KolaracMain = "KolaracMain"
    case KolaracS = "KolaracS"
    case Kinoteka200 = "Kinoteka200"
    case KinotekaPool = "KinotekaPool"
    case GalleryZvono = "GalleryZvono"

    var level: Int {
        switch self {
        case .KolaracMain:
            return 0
        case .KolaracS:
            return 1
        case .Kinoteka200:
            return 2
        case .KinotekaPool:
            return 3
        case .GalleryZvono:
            return 4
        }
    }
}

enum LocationFridayNight: String {
    case Magacin = "Magacin"

    var level: Int {
        return 0
    }
}

enum LocationSaturday: String {
    case KolaracMain = "KolaracMain"
    case KolaracS = "KolaracS"
    case Kinoteka200 = "Kinoteka200"
    case KinotekaCinema = "KinotekaCinema"
    case GalleryZvono = "GalleryZvono"

    var level: Int {
        switch self {
        case .KolaracMain:
            return 0
        case .KolaracS:
            return 1
        case .Kinoteka200:
            return 2
        case .KinotekaCinema:
            return 3
        case .GalleryZvono:
            return 4
        }
    }
}

enum EventType: String {
    case IntensiveWorkshop = "IntensiveWorkshop"
    case Workshop = "Workshop"
    case Screening = "Screening"
    case Lecture = "Lecture"
    case Performance = "Performance"
    case QA = "QA"
    case Panel = "Panel"
    case Venue = "Venue"
}

enum Programme: String {
    case Conference = "Conference"
    case Live = "Live"
    case Both = "Both"
    case IntensiveWorkshop = "IntensiveWorkshop"
}
 
enum LocationSaturdayNight: String {
    case DomOmladine = "DomOmladine"
    case ClubTube = "ClubTube"

    var level: Int {
        switch self {
        case .DomOmladine:
            return 0
        case .ClubTube:
            return 1
        }
    }
}