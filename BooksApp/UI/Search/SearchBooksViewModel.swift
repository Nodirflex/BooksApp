//
//  SearchBooksViewModel.swift
//  BooksApp
//
//  Created by Nodir on 20/12/22.
//

import Foundation
import Combine

protocol BooksViewModelProtocol: AnyObject {
    var bookItems: CurrentValueSubject<[VolumeItem], Never> { get }
    var errorMessageSubject: PassthroughSubject<String, Never> { get }
    
    func changeFavoriteState(for id: String)
}

protocol SearchBooksViewModelProtocol: BooksViewModelProtocol {
    var search: CurrentValueSubject<String, Never> { get }
    var reloadItem: PassthroughSubject<VolumeItem, Never> { get }
    var isFetching: PassthroughSubject<Bool, Never> { get }
    
    func checkIfFavorite(item: VolumeItem)
}

final class SearchBooksViewModel: SearchBooksViewModelProtocol {
    
    private var favorites = Set<String?>()
    private let booksService: BooksServiceProtocol
    private let storage: DataStorageServiceProtocol
    
    private var subscriptions = Set<AnyCancellable>()
    
    var search = CurrentValueSubject<String, Never>("")
    var bookItems = CurrentValueSubject<[VolumeItem], Never>([])
    var reloadItem = PassthroughSubject<VolumeItem, Never>()
    var isFetching = PassthroughSubject<Bool, Never>()
    var errorMessageSubject = PassthroughSubject<String, Never>()
    
    init(booksService: BooksServiceProtocol, storage: DataStorageServiceProtocol) {
        self.booksService = booksService
        self.storage = storage
        setupBindings()
    }
    
    func checkIfFavorite(item: VolumeItem) {
        item.isFavorite = favorites.contains(item.id)
    }
    
    func changeFavoriteState(for id: String) {
        guard let index = bookItems.value.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let item = bookItems.value[index]
        
        var shouldReloadItem = false
       
        if item.isFavorite {
            do {
                try storage.delete(for: id)
                item.isFavorite = false
                shouldReloadItem = true
            } catch let error as AppError {
                errorMessageSubject.send(error.message)
            } catch {
                errorMessageSubject.send(AppError.unknown.message)
            }
        } else {
            do {
                item.isFavorite = true
                try storage.save(item)
                shouldReloadItem = true
            } catch let error as AppError {
                errorMessageSubject.send(error.message)
            } catch {
                errorMessageSubject.send(AppError.unknown.message)
            }
        }
        
        if shouldReloadItem {
            reloadItem.send(item)
        }
    }
    
    private func setupBindings() {
        storage.volumeItemsSubject.sink { [weak self] items in
            self?.favorites = Set(items.map { $0.id ?? "" })
        }.store(in: &subscriptions)
        
        search
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                self.search(text: value)
            }.store(in: &subscriptions)
    }
    
    private func search(text: String) {
        guard !text.isEmpty else {
            self.isFetching.send(false)
            bookItems.send([])
            return
        }
        self.isFetching.send(true)
        let result = text.replacingOccurrences(of: " ", with: "+")
        booksService.search(by: result)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isFetching.send(false)
                switch completion {
                case .failure(let error):
                    self?.bookItems.send([])
                    self?.errorMessageSubject.send(error.message)
                default:
                    break
                }
            } receiveValue: { [weak self] model in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.bookItems.send(model.items)
                }
            }.store(in: &subscriptions)
    }
    
}
