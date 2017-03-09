//
//  AppStoryboard.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import UIKit

enum AppStoryboard: String {
    case main = "Main"

    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }

    func instantiate<T: UIViewController>(viewController: T.Type, withIdentifier id: String? = nil) -> T {
        let viewController = storyboard.instantiateViewController(withIdentifier: id ?? "\(T.self)") as! T
        viewController.loadViewIfNeeded()
        return viewController
    }
}
