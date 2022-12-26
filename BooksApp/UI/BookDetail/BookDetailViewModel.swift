//
//  BookDetailViewModel.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation
import UIKit.UIApplication
import Combine

protocol BookDetailViewModelProtocol: AnyObject {
    
    var item: VolumeItem { get }
    var errorMessageSubject: PassthroughSubject<String, Never> { get }
    var openURLSubject: PassthroughSubject<URL, Never> { get }
    var isFavoriteState: CurrentValueSubject<Bool, Never> { get }
    
    func changeState()
    func openURL()
}

final class BookDetailViewModel: BookDetailViewModelProtocol {
    
    private let storage: DataStorageServiceProtocol
    
    var errorMessageSubject = PassthroughSubject<String, Never>()
    var openURLSubject = PassthroughSubject<URL, Never>()
    var isFavoriteState: CurrentValueSubject<Bool, Never>
    let item: VolumeItem
    
    init(item: VolumeItem, storage: DataStorageServiceProtocol) {
        self.item = item
        self.storage = storage
        self.isFavoriteState = CurrentValueSubject<Bool, Never>(item.isFavorite)
    }
    
    func changeState() {
        
        if item.isFavorite {
            do {
                try storage.delete(for: item.id)
                item.isFavorite = false
            } catch let error as AppError {
                errorMessageSubject.send(error.message)
            } catch {
                errorMessageSubject.send(AppError.unknown.message)
            }
        } else {
            do {
                item.isFavorite = true
                try storage.save(item)
            } catch let error as AppError {
                errorMessageSubject.send(error.message)
            } catch {
                errorMessageSubject.send(AppError.unknown.message)
            }
        }
        isFavoriteState.send(item.isFavorite)
    }
    
    func openURL() {
        guard
            let previewLink = item.volumeInfo.previewLink,
            let url = URL(string: previewLink),
            UIApplication.shared.canOpenURL(url)
        else {
            errorMessageSubject.send(.localized(.invalidOpenFragmentUrl))
            return
        }
        
        openURLSubject.send(url)
    }
    
}
