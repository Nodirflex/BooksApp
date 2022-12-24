//
//  TabBarRouter.swift
//  BooksApp
//
//  Created by Nodir on 21/12/22.
//

import UIKit

protocol TabBarRouter: AnyObject {
    func tabBarController(container: DependencyContainerProtocol) -> UIViewController
}

extension TabBarRouter {
    func tabBarController(container: DependencyContainerProtocol) -> UIViewController {
        
        let dependencyContainer = container
        
        let searchTabBarStyle = TabBarStyle(title: .localized(.searchTitle), icon: .magnifyingglass)
        let searchVC = dependencyContainer.searchBooksVC().wrapInNavigation(tabBarStyle: searchTabBarStyle)
        
        let favoritesTabBarStyle = TabBarStyle(title: .localized(.favoritesTitle), icon: .starFill)
        let favoritesVC = dependencyContainer.favoritesVC().wrapInNavigation(tabBarStyle: favoritesTabBarStyle)
        
        let vc = TabBarViewController(viewControllers: [searchVC, favoritesVC])
        return vc
    }
}
