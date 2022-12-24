//
//  ImageLink.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

struct ImageLink: Codable {
    let image: String?
    
    init(image: String?) {
        self.image = image
    }
    
    enum CodingKeys: String, CodingKey {
        case image = "thumbnail"
    }
}
