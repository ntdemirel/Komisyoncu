//
//  APIClient.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 29.01.2026.
//

import Foundation

class APIClient {
    
    // Singleton, tek instance kullanmak için
    static let shared = APIClient()
    private init() {}
    
    private let baseURL = AppConfig.supabaseURL.absoluteString + "/rest/v1"
    private let anonKey = AppConfig.supabaseAnonKey
    private var accessToken: String {
        get async throws {
            return try await SupabaseProvider.client.auth.session.accessToken
        }
    }
    
    private func defaultHeaders() async throws -> [String : String] {
        let headers = [
            "apikey" : anonKey,
            "Authorization" : "Bearer \(try await accessToken)",
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        return headers
    }
    
    // DB için date decode ve encode ayarı
    private let decoder =  {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private let encoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private func makeRequest(endpoint: String, method: String, body: Data? = nil, returnResult: Bool = false) async throws -> URLRequest {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        let headers = try await defaultHeaders()
        
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        
        if returnResult {
            request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        }
        
        return request
    }
    
    private func handleResponse (data: Data, response: URLResponse) throws{
        
        guard let httpResponse =   response as? HTTPURLResponse else {
            throw  APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299: //Başarılı
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            let message = String (data: data, encoding: .utf8)
            throw APIError.httpError(statueCode: httpResponse.statusCode, message: message)
        }
        
    }
    
    
    func get<T: Decodable>(endpoint: String) async throws -> T {
        
        let request = try await makeRequest(endpoint: endpoint, method: "GET")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try handleResponse(data: data, response: response)
        
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func post <T: Encodable, R: Decodable> (endpoint: String, body: T) async throws -> R {
        
        let bodyData = try encoder.encode(body)
        let request = try await makeRequest(endpoint: endpoint, method: "POST", body: bodyData, returnResult: true)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try handleResponse(data: data, response: response)
        
        do{
            let array = try decoder.decode([R].self, from: data)
            guard let first = array.first else {
                throw APIError.invalidResponse
            }
            return first
        } catch {
            throw APIError.decodingError(error)
        }
        
    }
    
    func patch <T: Encodable>(endpoint: String, body: T) async throws {
        
        let bodyData = try encoder.encode(body)
        
        var request = try await makeRequest(endpoint: endpoint, method: "PATCH")
        
        let (data , response) = try await URLSession.shared.data(for: request)
        
        try handleResponse(data: data, response: response)
        
    }
    
}
