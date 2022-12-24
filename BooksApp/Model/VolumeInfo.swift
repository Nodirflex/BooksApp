//
//  VolumeInfo.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

class VolumeInfo: Decodable {
    let title: String?
    let authors: [String]?
    let imageLinks: ImageLink?
    let previewLink: String?
    let description: String?
    
    init(title: String?, authors: [String]?, image: String?, previewLink: String?, description: String?) {
        self.title = title
        self.authors = authors
        self.imageLinks = ImageLink(image: image)
        self.previewLink = previewLink
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case title, authors, imageLinks, previewLink, description
    }
}
