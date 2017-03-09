//
//  LocationService.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

protocol LocationServiceProtocol {
    /// See `CLError` for reference.
    var error: Observable<(LocationServiceProtocol, Error)> { get }

    func authorize() -> Observable<(LocationServiceProtocol, CLAuthorizationStatus)>
    func requestLocation() -> Observable<(LocationServiceProtocol, [CLLocation])>
    func startUpdatingLocation() -> Observable<(LocationServiceProtocol, [CLLocation])>
    func stopUpdatingLocation()
}

final class LocationService: LocationServiceProtocol {
    private var deallocating = ReplaySubject<()>.create(bufferSize: 1)

    private let locationManager: CLLocationManager
    private let locationManagerDelegate: LocationManagerDelegate

    private var authorizationStatus: Observable<CLAuthorizationStatus> {
        return Observable.concat([
                .just(CLLocationManager.authorizationStatus()),
                locationManagerDelegate.didChangeAuthorization
                    .map { _, authorizationStatus in authorizationStatus }
            ])
            .takeUntil(deallocating)
    }

    var error: Observable<(LocationServiceProtocol, Error)> {
        return locationManagerDelegate.didFailWithError
            .flatMapLatest { [weak self] _, error -> Observable<(LocationServiceProtocol, Error)> in
                guard let `self` = self
                else { return .empty() }
                return .just((self, error))
            }
            .takeUntil(deallocating)
    }

    init() {
        self.locationManagerDelegate = LocationManagerDelegate()

        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self.locationManagerDelegate
    }

    deinit {
        deallocating.onNext()
        deallocating.onCompleted()
    }

    func authorize() -> Observable<(LocationServiceProtocol, CLAuthorizationStatus)> {
        return authorizationStatus
            .do(onSubscribe: { [weak self] in
                self?.locationManager.requestWhenInUseAuthorization()
            })
            .flatMapLatest { [weak self] authorizationStatus -> Observable<(LocationServiceProtocol, CLAuthorizationStatus)> in
                guard let `self` = self
                else { return .empty() }
                return .just((self, authorizationStatus))
            }
            .takeUntil(deallocating)
    }

    func requestLocation() -> Observable<(LocationServiceProtocol, [CLLocation])> {
        return locationManagerDelegate.didUpdateLocations
            .do(onSubscribe: { [weak self] in
                self?.locationManager.requestLocation()
            })
            .flatMapLatest { [weak self] _, locations -> Observable<(LocationServiceProtocol, [CLLocation])> in
                guard let `self` = self
                else { return .empty() }
                return .just((self, locations))
            }
            .take(1)
            .takeUntil(deallocating)
    }

    func startUpdatingLocation() -> Observable<(LocationServiceProtocol, [CLLocation])> {
        return locationManagerDelegate.didUpdateLocations
            .do(onSubscribe: { [weak self] in
                self?.locationManager.startUpdatingLocation()
                // TODO: Share this subscription and stop updating location on dispose.
            })
            .flatMapLatest { [weak self] _, locations -> Observable<(LocationServiceProtocol, [CLLocation])> in
                guard let `self` = self
                else { return .empty() }
                return .just((self, locations))
            }
            .takeUntil(deallocating)
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
        var didUpdateLocations: Observable<(CLLocationManager, [CLLocation])> { return didUpdateLocationsSubject }
        var didFailWithError: Observable<(CLLocationManager, Error)> { return didFailWithErrorSubject }
        var didChangeAuthorization: Observable<(CLLocationManager, CLAuthorizationStatus)> { return didChangeAuthorizationSubject }
        var didPauseLocationUpdates: Observable<CLLocationManager> { return didPauseLocationUpdatesSubject }
        var didResumeLocationUpdates: Observable<CLLocationManager> { return didResumeLocationUpdatesSubject }

        private let didUpdateLocationsSubject = PublishSubject<(CLLocationManager, [CLLocation])>()
        private let didFailWithErrorSubject = PublishSubject<(CLLocationManager, Error)>()
        private let didChangeAuthorizationSubject = PublishSubject<(CLLocationManager, CLAuthorizationStatus)>()
        private let didPauseLocationUpdatesSubject = PublishSubject<CLLocationManager>()
        private let didResumeLocationUpdatesSubject = PublishSubject<CLLocationManager>()

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            didUpdateLocationsSubject.onNext(manager, locations)
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            didFailWithErrorSubject.onNext(manager, error)
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            didChangeAuthorizationSubject.onNext(manager, status)
        }

        func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
            didPauseLocationUpdatesSubject.onNext(manager)
        }

        func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
            didResumeLocationUpdatesSubject.onNext(manager)
        }
    }
}
