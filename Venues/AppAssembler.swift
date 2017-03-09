//
//  AppAssembler.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import UIKit
import Swinject

func appAssembler() throws -> Assembler {
    return try Assembler(assemblies: [AppAssembly(), ServiceAssembly()])
}

final class AppAssembly: Assembly {
    static let mainWindowKey = "main"

    func assemble(container c: Container) {
        c.register(AppController.self) { c in
            AppController(
                window: c.resolve(UIWindow.self, name: AppAssembly.mainWindowKey)!,
            	locationService: c.resolve(LocationServiceProtocol.self)!,
                foursquareClient: c.resolve(FoursquareClientProtocol.self)!
            )
        }
        c.register(UIWindow.self, name: AppAssembly.mainWindowKey) { _ in
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .white
            return window
        }
    }
}

final class ServiceAssembly: Assembly {
    func assemble(container c: Container) {
        c.register(LocationServiceProtocol.self) { _ in LocationService() }
        c.register(FoursquareClientProtocol.self) { c in
            FoursquareClient(requestFactory: c.resolve(FoursquareRequestFactoryProtocol.self)!)
        }
        c.register(FoursquareRequestFactoryProtocol.self) { _ in
            // TODO: Move to a configuration provider.
            let clientID = "55GGUXSEP1RBUGTNCB52ZHVBFWDXQX1B2ARHH5GDOSAHOSTW"
            let clientSecret = "LGS5HV5ZFUGJJTXSEWDQZ2GORIBYTQH45MY1RE0YAWNHBFON"
        	return FoursquareRequestFactory(clientID: clientID, clientSecret: clientSecret)
        }
    }
}
