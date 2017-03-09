//
//  AppDelegate.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/2/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appController: AppController = try! appAssembler().resolver.resolve(AppController.self)!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        appController.start()
        return true
    }
}
