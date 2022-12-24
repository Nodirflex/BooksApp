//
//  ImageService.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation
import Combine
import UIKit.UIImage

protocol ImageServiceProtocol {
    
    var maximumCacheSize: Int { get }
    
    func fetchImage(for urlString: String?) -> AnyPublisher<UIImage?, URLError>
}

final class ImageService: ImageServiceProtocol {
    
    private struct CachedImage {
        let url: URL
        
        let data: Data
    }
    
    private var cachedImages: [CachedImage] = []
    
    var maximumCacheSize: Int = 512 * 1024
    
    func fetchImage(for urlString: String?) -> AnyPublisher<UIImage?, URLError> {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            let image: UIImage? = .bookClosed
            return Just(image)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        
        if let image = cachedImage(for: url) {
            return Just(image)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { [weak self] result in
                self?.cacheImage(result.data, for: url)
                return UIImage(data: result.data)
            }.eraseToAnyPublisher()
    }
    
    private func cachedImage(for url: URL) -> UIImage? {
        guard let data = cachedImages.first(where: { $0.url == url } )?.data else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    private func cacheImage(_ data: Data, for url: URL) {
        
        var cacheSize = cachedImages.reduce(0) { result, cachedImage -> Int in
            result + cachedImage.data.count
        }
        
        while cacheSize > maximumCacheSize {
            let oldestCachedImage = cachedImages.removeFirst()
            
            cacheSize -= oldestCachedImage.data.count
        }
        
        let cachedImage = CachedImage(url: url, data: data)
        
        cachedImages.append(cachedImage)
    }
    
}
