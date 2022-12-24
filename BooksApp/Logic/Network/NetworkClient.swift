//
//  ApiClient.swift
//  BooksApp
//
//  Created by Nodir on 20/12/22.
//

import Foundation
import Combine

protocol NetworkClientProtocol {
    func makeRequest<T: Decodable>(_ request: NetworkRequest) -> AnyPublisher<T, AppError>
}

final class NetworkClient: NetworkClientProtocol {
    
    func makeRequest<T: Decodable>(_ request: NetworkRequest) -> AnyPublisher<T, AppError> {
        let urlRequest = prepareURLRequest(from: request)
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ result in
                let decoder = JSONDecoder()
                guard
                    let urlResponse = result.response as? HTTPURLResponse,
                    (200...299).contains(urlResponse.statusCode)
                else {
                    throw AppError.failedRequest
                }
                
                do {
                    return try decoder.decode(T.self, from: result.data)
                } catch {
                    throw AppError.invalidResponse
                }
            })
            .mapError { error -> AppError in
                switch error {
                case let apiError as AppError:
                    return apiError
                case URLError.notConnectedToInternet:
                    return AppError.unreachable
                default:
                    return AppError.failedRequest
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func prepareURLRequest(from request: NetworkRequest) -> URLRequest {
        let urlString = (request.webServiceURL + request.apiPath).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.httpMethod = request.requestType.rawValue
        urlRequest.addHeaders(request.headers)
        return urlRequest
    }
}
