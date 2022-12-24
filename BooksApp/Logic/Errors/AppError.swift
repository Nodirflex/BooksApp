//
//  AppError.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

enum AppError: Error {
    
    case failedRequest
    case invalidResponse
    case unreachable
    case unknown
    case invalid(String)
    
    var message: String {
        switch self {
        case .unreachable:
            return "Нет подключения к интернету"
        case .failedRequest,
                .invalidResponse:
            return "Не удалось получить книги по запросу"
        case .unknown:
            return "Произошла неизвестная ошибка"
        case .invalid(let message):
            return message
        }
    }
    
}
