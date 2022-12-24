//
//  BookDetailViewModel.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

protocol BookDetailViewModelProtocol: AnyObject {
    
    var item: VolumeItem { get }
    
}

final class BookDetailViewModel: BookDetailViewModelProtocol {
    
    let item: VolumeItem
    
    init(item: VolumeItem) {
        self.item = item
    }
    
}
