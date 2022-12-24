//
//  ViewControllerFactory.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

protocol ViewControllerFactory {
    func searchBooksVC() -> SearchBookViewController
    func favoritesVC() -> FavoritesViewController
    func bookDetailVC(item: VolumeItem) -> BookDetailViewController
}
