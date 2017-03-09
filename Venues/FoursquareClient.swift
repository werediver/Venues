//
//  FoursquareClient.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/2/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift

protocol FoursquareClientProtocol {
    func venues(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance?, limit: Int?) -> Observable<[Venue]>
    func venuePhotos(coordinate: CLLocationCoordinate2D, venueID id: String, limit: Int?) -> Observable<[VenuePhoto]>
    func image(url: URL) -> Observable<UIImage>
}

final class FoursquareClient: FoursquareClientProtocol {
    enum Failure: Error {
        case invalidData(Data?, URLResponse?)
        case invalidJSON(String?, URLResponse?)
    }

    private let urlSession = URLSession.shared
    private let requestFactory: FoursquareRequestFactoryProtocol

    init(requestFactory: FoursquareRequestFactoryProtocol) {
        self.requestFactory = requestFactory
    }

    func venues(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance?, limit: Int?) -> Observable<[Venue]> {
        let params = VenueSearchRequestParameters(coordinate: coordinate, limit: limit, intent: .browse, radius: radius.map(Int.init))
        let req = requestFactory.request(.venueSearch(params))
        return textTask(with: req)
            .flatMap { text, urlResponse -> Observable<[Venue]> in
                if let response = text.flatMap({ VenueSearchResponse(JSONString: $0) }) {
                    return .just(response.venues)
                } else {
                    return .error(Failure.invalidJSON(text, urlResponse))
                }
            }
    }

    func venuePhotos(coordinate: CLLocationCoordinate2D, venueID id: String, limit: Int?) -> Observable<[VenuePhoto]> {
        let params = VenuePhotosRequestParameters(coordinate: coordinate, venueID: id, limit: limit, offset: nil)
        let req = requestFactory.request(.venuePhotos(params))
        return textTask(with: req)
            .map { text, urlResponse -> [VenuePhoto] in
                if let response = text.flatMap({ VenuePhotoResponse(JSONString: $0) }) {
                    return response.items
                } else {
                    throw Failure.invalidJSON(text, urlResponse)
                }
            }
    }

    // TODO: Consider extracting `image(url:)` function to a separate service.
    func image(url: URL) -> Observable<UIImage> {
        /// The compressed image data is cached in `URLSession` cache.
        return dataTask(with: .success(URLRequest(url: url)))
            .map { data, urlResponse -> UIImage in
                if let image = data.flatMap(UIImage.init(data:)) {
                    return image
                } else {
                    throw Failure.invalidData(data, urlResponse)
                }
            }
    }

    private func textTask(with req: Result<URLRequest>) -> Observable<(String?, URLResponse?)> {
        return dataTask(with: req)
            .flatMap { data, urlResponse -> Observable<(String?, URLResponse?)> in
                if let data = data,
                   let text = String(data: data, encoding: .utf8)
                {
                    return .just((text, urlResponse))
                } else {
                    return .error(Failure.invalidData(data, urlResponse))
                }
            }
    }

    private func dataTask(with req: Result<URLRequest>) -> Observable<(Data?, URLResponse?)> {
        return req.iif(
            success: { req in
                Observable.create { [weak self] observer in
                    guard let `self` = self
                    else {
                        observer.on(.error(CommonFailure.weakSelfIsNil))
                        return Disposables.create()
                    }

                    let task = self.urlSession.dataTask(with: req) { data, urlResponse, error in
                        if let error = error {
                            observer.on(.error(error))
                        } else {
                            observer.on(.next(data, urlResponse))
                            observer.on(.completed)
                        }
                    }
                    task.resume()

                    return Disposables.create {
                        task.cancel()
                    }
                }
                .shareReplay(1)
            },
            failure: { error in
                .error(error)
            }
        )
    }
}
