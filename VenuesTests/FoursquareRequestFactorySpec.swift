//
//  FoursquareRequestFactorySpec.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/9/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Quick
import Nimble
import CoreLocation
@testable import Venues

final class FoursquareRequestFactorySpec: QuickSpec {
    private static let clientID = "CLIENT_ID"
    private static let clientSecret = "CLIENT_SECRET"

    override func spec() {
        describe("FoursquareRequestFactory") {
            var sut: FoursquareRequestFactory!

            beforeEach {
                sut = FoursquareRequestFactory(clientID: FoursquareRequestFactorySpec.clientID, clientSecret: FoursquareRequestFactorySpec.clientSecret)
            }

            it("constructs a request for venue search") {
                let params = VenueSearchRequestParameters(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2), limit: 3, intent: .browse, radius: 4)
                let result = sut.request(.venueSearch(params))
                expect(result.value).toNot(beNil())
            }

            it("constructs a request for venue photos") {
                let params = VenuePhotosRequestParameters(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2), venueID: "VENUE_ID", limit: 3, offset: 4)
                let result = sut.request(.venuePhotos(params))
                expect(result.value).toNot(beNil())
            }
        }
    }
}
