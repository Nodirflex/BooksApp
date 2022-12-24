//
//  ApiEndpoint.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

enum ApiEndpoint {
    
    static let api = "https://www.googleapis.com/books/v1"
    static let apiKey = "AIzaSyB_S674UHT4XHmdUaLJ9Z9vq2ia8_u0Uvw"
    static let headers = [
        "Content-Type": "application/json",
        "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
    ]
    
    enum Volume {
        static let search = "/volumes?q=%@&key=%@"
    }
    
}
