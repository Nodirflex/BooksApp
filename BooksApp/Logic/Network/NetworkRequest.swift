//
//  NetworkRequest.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

protocol NetworkRequest {
    var webServiceURL: String { get }
    var apiPath: String { get }
    var requestType: HTTPMethod { get }
    var headers: [String: String] { get }
}

extension NetworkRequest {
    var webServiceURL: String { ApiEndpoint.api }
    var apiPath: String { "" }
    var requestType: HTTPMethod { .get }
    var headers: [String: String] {
        ["Content-Type": "application/json",
         "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""] }
}
