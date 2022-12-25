//
//  FavoritesViewModel.swift
//  BooksApp
//
//  Created by Nodir on 21/12/22.
//

import Foundation
import Combine
import UIKit.UIApplication

final class FavoritesViewModel: BooksViewModelProtocol {
    
    private var subscriptions = Set<AnyCancellable>()
    private let storage: DataStorageServiceProtocol
    
    var bookItems = CurrentValueSubject<[VolumeItem], Never>([])
    var errorMessageSubject = PassthroughSubject<String, Never>()
    var openURLSubject = PassthroughSubject<URL, Never>()
    
    init(storage: DataStorageServiceProtocol) {
        self.storage = storage
        setupBindings()
        fetch()
    }
    
    func changeFavoriteState(for id: String) {
        guard let index = bookItems.value.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let item = bookItems.value[index]
        
        item.isFavorite = false
        
        do {
            try storage.delete(for: item.id)
        } catch let error as AppError {
            errorMessageSubject.send(error.message)
        } catch {
            errorMessageSubject.send(AppError.unknown.message)
        }
    }
    
    func openURL(for id: String) {
        guard
            let previewLink = bookItems.value.first(where: { $0.id == id })?.volumeInfo.previewLink,
            let url = URL(string: previewLink),
            UIApplication.shared.canOpenURL(url)
        else {
            errorMessageSubject.send(.localized(.invalidOpenFragmentUrl))
            return
        }
        
        openURLSubject.send(url)
    }
    
    private func fetch() {
        do {
            try storage.fetch()
        } catch let error as AppError {
            errorMessageSubject.send(error.message)
        } catch {
            errorMessageSubject.send(AppError.unknown.message)
        }
    }
    
    private func setupBindings() {
        storage.volumeItemsSubject.sink { [weak self] items in
            self?.bookItems.value = items.map { VolumeItem(model: $0) }
        }.store(in: &subscriptions)
    }
    
}
