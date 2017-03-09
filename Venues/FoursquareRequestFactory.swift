//
//  FoursquareRequestFactory.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation

enum FoursquareRequestSpec {
    case venueSearch(VenueSearchRequestParameters)
    case venuePhotos(VenuePhotosRequestParameters)
}

protocol FoursquareRequestFactoryProtocol {
    func request(_ spec: FoursquareRequestSpec) -> Result<URLRequest>
}

final class FoursquareRequestFactory: FoursquareRequestFactoryProtocol {
    enum Failure: Error {
        case invalidURLComponents(URLComponents)
    }

    private let baseURLString = "https://api.foursquare.com/v2/"
    private let clientID: String
    private let clientSecret: String

    init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }

    func request(_ spec: FoursquareRequestSpec) -> Result<URLRequest> {
        let recipe: Recipe
        switch spec {
        case let .venueSearch(params):
            recipe = venueSearch(params)
        case let .venuePhotos(params):
            recipe = venuePhotos(params)
        }

        var comps = URLComponents(string: baseURLString)!
        comps.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "v", value: "20170308"),
            URLQueryItem(name: "m", value: "foursquare")
        ]

        let req = recipe.prepareURLComponents(comps)
            .flatMap { comps in
                comps.url
                    .map { url in URLRequest(url: url) }
                    .map(Result.success)
                ?? .failure(Failure.invalidURLComponents(comps))
            }
            .flatMap(recipe.prepareURLRequest)

        return req
    }

    private func venueSearch(_ params: VenueSearchRequestParameters) -> Recipe {
        return Recipe(prepareURLComponents: { srcComps in
                var comps = srcComps
                comps.path += "venues/search"
                comps.queryItems = (comps.queryItems ?? []) + Array<URLQueryItem?>([
                    params.coordinate.map { URLQueryItem(name: "ll", value: "\($0.latitude),\($0.longitude)") },
                    params.radius.map { URLQueryItem(name: "radius", value: "\($0)") },
                    params.intent.map { URLQueryItem(name: "intent", value: $0.rawValue) },
                    params.limit.map { URLQueryItem(name: "limit", value: "\($0)") }
                ]).flatMap { $0 }
                return .success(comps)
            }, prepareURLRequest: { .success($0) })
    }

    private func venuePhotos(_ params: VenuePhotosRequestParameters) -> Recipe {
        return Recipe(prepareURLComponents: { srcComps in
                var comps = srcComps
                comps.path += "venues/\(params.venueID)/photos"
                comps.queryItems = (comps.queryItems ?? []) + Array<URLQueryItem?>([
                    params.coordinate.map { URLQueryItem(name: "ll", value: "\($0.latitude),\($0.longitude)") },
                    params.limit.map { URLQueryItem(name: "limit", value: "\($0)") },
                    params.offset.map { URLQueryItem(name: "offset", value: "\($0)") }
                ]).flatMap { $0 }
                return .success(comps)
            }, prepareURLRequest: { .success($0) })
    }

    private struct Recipe {
        let prepareURLComponents: (URLComponents) -> Result<URLComponents>
        let prepareURLRequest: (URLRequest) -> Result<URLRequest>
    }
}
