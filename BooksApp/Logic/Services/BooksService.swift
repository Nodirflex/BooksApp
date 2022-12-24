//
//  BooksService.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation
import Combine

protocol BooksServiceProtocol {
    func search(by text: String) -> AnyPublisher<ModelVolume, AppError>
}

final class BooksService: BooksServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func search(by text: String) -> AnyPublisher<ModelVolume, AppError> {
        let request = SearchRequest(text: text)
        return networkClient.makeRequest(request)
    }
    
    private struct SearchRequest: NetworkRequest {
        var apiPath: String
        
        init(text: String) {
            let path = String(format: ApiEndpoint.Volume.search, text, ApiEndpoint.apiKey)
            self.apiPath = path
        }
    }

}
