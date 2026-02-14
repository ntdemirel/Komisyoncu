//
//  APIError.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 29.01.2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statueCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response from server"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP Error (\(statusCode))"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .unknown:
            return "Unknown error"
            
        }
    }
}
