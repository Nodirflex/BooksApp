//
//  UIViewController + NavigationController.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import UIKit

struct TabBarStyle {
    let title: String
    let icon: UIImage?
}

extension UIViewController {
    func wrapInNavigation(tabBarStyle: TabBarStyle? = nil) -> UINavigationController {
        let isNavigationController = isKind(of: UINavigationController.self)

        if isNavigationController {
            return self as! UINavigationController
        }

        let navigationController = UINavigationController(rootViewController: self)

        if let tabBarStyle = tabBarStyle {
            navigationController.tabBarItem.title = tabBarStyle.title
            navigationController.tabBarItem.image = tabBarStyle.icon
        }

        return navigationController
    }
}
