//
//  DependencyContainer.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

protocol DependencyContainerProtocol: ViewModelFactory, ViewControllerFactory {
    var networkClient: NetworkClientProtocol { get set }
    var storage: DataStorageServiceProtocol { get set }
    var booksService: BooksServiceProtocol { get set }
    var imageService: ImageServiceProtocol { get set }
}

final class DependencyContainer: DependencyContainerProtocol {
    
    private init() { }
    
    static let shared = DependencyContainer()
    
    lazy var networkClient: NetworkClientProtocol = NetworkClient()
    lazy var storage: DataStorageServiceProtocol = DataStorageService()
    lazy var booksService: BooksServiceProtocol = BooksService(networkClient: networkClient)
    lazy var imageService: ImageServiceProtocol = ImageService()
}

extension DependencyContainer {
    
    func searchVM() -> SearchBooksViewModelProtocol {
        let booksService = DependencyContainer.shared.booksService
        let storage = DependencyContainer.shared.storage
        let searchVM = SearchBooksViewModel(booksService: booksService, storage: storage)
        return searchVM
    }
    
    func favoritesVM() -> BooksViewModelProtocol {
        let favoritesVM = FavoritesViewModel(storage: DependencyContainer.shared.storage)
        return favoritesVM
    }
    
    func bookDetailVM(item: VolumeItem) -> BookDetailViewModelProtocol {
        let storage = DependencyContainer.shared.storage
        let bookDetailVM = BookDetailViewModel(item: item, storage: storage)
        return bookDetailVM
    }
    
}

extension DependencyContainer {
    
    func searchBooksVC() -> SearchBookViewController {
        let searchViewModel = searchVM()
        let imageService = DependencyContainer.shared.imageService
        let searchVC = SearchBookViewController(viewModel: searchViewModel, imageService: imageService)
        return searchVC
    }
    
    func favoritesVC() -> FavoritesViewController {
        let favoritesViewModel = favoritesVM()
        let imageService = DependencyContainer.shared.imageService
        let favotiresVC = FavoritesViewController(viewModel: favoritesViewModel, imageService: imageService)
        return favotiresVC
    }
    
    func bookDetailVC(item: VolumeItem) -> BookDetailViewController {
        let bookDetailViewModel = bookDetailVM(item: item)
        let imageService = DependencyContainer.shared.imageService
        let bookDetailVC = BookDetailViewController(viewModel: bookDetailViewModel, imageService: imageService)
        return bookDetailVC
    }
    
}
