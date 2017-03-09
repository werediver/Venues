//
//  VenueSearch.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

struct VenueSearchRequestParameters {
    enum Intent: String {
        case checkin
        case browse
        case global
        case match
    }

    let coordinate: CLLocationCoordinate2D?
    /// Number of results to return, up to 50.
    let limit: Int?
    /// The intent in performing the search. If no value is specified, defaults to `checkin`.
    let intent: Intent?
    /// Limit results to venues within this many meters of the specified location. Defaults to a city-wide area. Only valid for requests with `intent=browse`, or requests with `intent=checkin` and `categoryId` or `query`. Does not apply to `match` intent requests. The maximum supported radius is currently 100,000 meters.
    let radius: Int?
}

struct VenueSearchResponse {
    var venues: [Venue] = []
}

extension VenueSearchResponse: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        venues <- map["response.venues"] // TODO: Define a separate common response-structure.
    }
}

struct Venue {
    var id: String!
    var name: String!
}

extension Venue: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
