//
//  ViewModelFactory.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

protocol ViewModelFactory {
    func searchVM() -> BooksViewModelProtocol & SearchBooksViewModelProtocol
    func favoritesVM() -> BooksViewModelProtocol
    func bookDetailVM(item: VolumeItem) -> BookDetailViewModelProtocol
}
