//
//  VenuePhoto.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/9/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

struct VenuePhotosRequestParameters {
    let coordinate: CLLocationCoordinate2D?
    let venueID: String
    let limit: Int?
    let offset: Int?
}

struct VenuePhotoResponse {
    var count: Int!
    var items: [VenuePhoto]!
}

extension VenuePhotoResponse: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        count <- map["response.photos.count"]
        items <- map["response.photos.items"]
    }
}

struct VenuePhoto {
    var id: String!
    var prefix: String!
    var suffix: String!

    func url(size: Size) -> URL? {
        return URL(string: prefix + size.description + suffix)
    }

    enum Size: CustomStringConvertible {
        enum Value: Int {
            case px36  =  36
            case px100 = 100
            case px300 = 300
            case px500 = 500
        }

        case wh(Value, Value)
        case original
        case cap(Value)
        case width(Value)
        case height(Value)

        var description: String {
            switch self {
            case let .wh(w, h):
                return "\(w.rawValue)x\(h.rawValue)"
            case .original:
                return "original"
            case let .cap(value):
                return "cap\(value.rawValue)"
            case let .width(value):
                return "width\(value.rawValue)"
            case let .height(value):
                return "height\(value.rawValue)"
            }
        }
    }
}

extension VenuePhoto: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        prefix <- map["prefix"]
        suffix <- map["suffix"]
    }
}
