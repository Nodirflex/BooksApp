//
//  BookDetailRouter.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import UIKit.UIViewController

protocol BookDetailRouter {
    func openBookDetail(item: VolumeItem, dependencyContainer: DependencyContainerProtocol)
}

extension BookDetailRouter where Self: UIViewController {
    func openBookDetail(item: VolumeItem,
                        dependencyContainer: DependencyContainerProtocol = DependencyContainer.shared) {
        let bookDetailVC = dependencyContainer.bookDetailVC(item: item)
        bookDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bookDetailVC, animated: true)
    }
}
