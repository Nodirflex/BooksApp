//
//  VolumeItem.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

class VolumeItem: Decodable, Hashable {
    
    let id: String?
    let volumeInfo: VolumeInfo
    var isFavorite = false
    var image: String? {
        volumeInfo.imageLinks?.image
    }
    var itemId: String {
        String(describing: "\(id ?? "")\(isFavorite)")
    }
    
    init(model: VolumeItemModel) {
        self.id = model.id
        self.isFavorite = model.isFavorite
        
        let authors = model.authors?.components(separatedBy: ", ")
        self.volumeInfo = VolumeInfo(title: model.title,
                                     authors: authors,
                                     image: model.image,
                                     previewLink: model.previewLink,
                                     description: model.bookDescription)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, volumeInfo
    }
    
    static func == (lhs: VolumeItem, rhs: VolumeItem) -> Bool {
        lhs.itemId == rhs.itemId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemId)
    }
}
