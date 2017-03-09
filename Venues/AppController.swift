//
//  AppController.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift

final class AppController {
    let window: UIWindow
    let locationService: LocationServiceProtocol
    let foursquareClient: FoursquareClientProtocol

    init(window: UIWindow, locationService: LocationServiceProtocol, foursquareClient: FoursquareClientProtocol) {
        // TODO: Consider extracting a router to manage UI presentation.
        self.window = window
        self.locationService = locationService
        self.foursquareClient = foursquareClient
    }

    func start() {
        window.makeKeyAndVisible()

        let overviewViewController = AppStoryboard.main.instantiate(viewController: OverviewViewController.self)
        overviewViewController.loadViewIfNeeded()
        overviewViewController.setup(model: self)

        let rootNavigationController = UINavigationController(rootViewController: overviewViewController)

        window.rootViewController = rootNavigationController
    }
}

extension AppController: OverviewModelProtocol {
    func getOverviewData() -> Observable<[PhotoCellData]> {
        return locationService.authorize()
            .flatMapLatest { locationService, authorizationStatus -> Observable<[CLLocation]> in
                if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
                    return locationService.requestLocation()
                        .map { _, locations in locations }
                } else {
                    return .empty()
                }
            }
            .flatMapLatest { [weak self] locations -> Observable<(CLLocationCoordinate2D, [Venue])> in
                guard let `self` = self
                else { throw CommonFailure.weakSelfIsNil }
                let coordinate = locations.last!.coordinate
                return self.foursquareClient.venues(coordinate: coordinate, radius: 100000, limit: 50)
                    .map { (coordinate, $0) }
            }
            .flatMapLatest { [weak self] coordinate, venues -> Observable<[PhotoCellData]> in
                guard let `self` = self
                else { throw CommonFailure.weakSelfIsNil }
                return Observable.from(venues.map { self.foursquareClient.venuePhotos(coordinate: coordinate, venueID: $0.id, limit: 200) })
                    .merge()
                    .map { venuePhotos in
                        venuePhotos.flatMap { venuePhoto in
                            venuePhoto.url(size: .wh(.px100, .px100)).map(PhotoCellData.init(imageURL:))
                        }
                    }
                    // The use of `reduce` here is suboptimal, but it's quick to implement.
                    .reduce(Array<PhotoCellData>()) { acc, items in
                        Array((acc + items).prefix(100)) // Limit the total number of images to 100 as required by the task.
                    }
            }
    }

    func image(url: URL) -> Observable<UIImage> {
        return foursquareClient.image(url: url)
    }
}
