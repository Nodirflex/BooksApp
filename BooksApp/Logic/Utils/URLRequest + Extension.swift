//
//  URLRequest + Extension.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

extension URLRequest {

    mutating func addHeaders(_ headers: [String: String]) {
        headers.forEach { header, value in
            addValue(value, forHTTPHeaderField: header)
        }
    }

}
