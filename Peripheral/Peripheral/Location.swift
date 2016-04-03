//
//  Location.swift
//  Peripheral
//
//  Created by travis on 2016-03-21.
//  Copyright © 2016 C4. All rights reserved.
//

import Foundation

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

enum LocationMonday: String {
    case UKParobrod0 = "UKParobrod0"
    case UKParobrod1 = "UKParobrod1"
    case UKParobrod2 = "UKParobrod2"
    case UKParobrod3 = "UKParobrod3"

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
        }
    }
}

enum LocationTuesday: String {
    case UKParobrod0 = "UKParobrod0"
    case UKParobrod1 = "UKParobrod1"
    case UKParobrod2 = "UKParobrod2"
    case UKParobrod3 = "UKParobrod3"
    case KinotekaCinema = "KinotekaCinema"
    case Kinoteka200 = "Kinoteka200"
    case Kinoteka = "Kinoteka"

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

enum EventType: Int {
    case IntensiveWorkshop
    case Workshop
    case Screening
    case Lecture
    case Performance
    case QA
    case Panel
    case Venue
}

enum Programme: Int {
    case Conference
    case Live
    case Both
    case IntensiveWorkshop
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