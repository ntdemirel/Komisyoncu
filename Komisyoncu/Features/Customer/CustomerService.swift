//
//  CustomerService.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 4.02.2026.
//

import Foundation


class CustomerService {
    
    private let api = APIClient.shared
    
    static let defaultPageSize = 50
    
    //MARK: - CREATE
    
    //Yeni Müşteri Oluştur
    func createCustomer(_ customer: Customer) async throws -> Customer {
        let response: CustomerResponse = try await api.post(endpoint: "/customers", body: customer.toRequest())
        return Customer(from: response)
    }
    
    //MARK: - READ
    
    // Müşterilerileri Getir (Pagination)
    func fetchCustomers ( isArchived: Bool = false, limit: Int = defaultPageSize, offset: Int = 0) async throws -> [Customer] {
        let endpoint = "/customers?is_archived=eq.\(isArchived)&order=name.asc&limit=\(limit)&offset=\(offset)"
        let responses : [CustomerResponse] = try await api.get(endpoint: endpoint )
        return responses.map{Customer(from: $0)}
    }
    

    
    func searchCustomers(query: String, isArchived: Bool = false, limit: Int = defaultPageSize, offset: Int = 0) async throws -> [Customer] {
        //Safe URL
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return []}
        
        let endpoint = "/customers?is_archived=eq.\(isArchived)&or=(company_name.ilike.*\(encodedQuery)*,contact_person.ilike.*\(encodedQuery)*,email.ilike.*\(encodedQuery)*)&order=name.asc&limit=\(limit)&offset=\(offset)"
        
        let responses: [CustomerResponse] = try await api.get(endpoint: endpoint)
        return responses.map {Customer(from: $0)}
    }
    
    
    //MARK: - UPDATE
    
    //Müşteri bilgileri güncelle
    func updateCustomer(_ customer: Customer) async throws {
        let endpoint = "/customers?id=eq.\(customer.id)"
        try await api.patch(endpoint: endpoint, body: customer.toRequest())
    }
    
    //MARK: - ARCHIVE (Soft Delete)
    
    //Müşteriyi arşivle (geçici silmek)
    func archiveCustomer(id: UUID) async throws {
        let endpoint = "/customers?id=eq.\(id)"
        try await api.patch(endpoint: endpoint, body: ["is_archived": true])
    }
    
    //Müşteriyi arşivden çıkar
    func unarchiveCustomer(id: UUID) async throws {
        let endpoint = "/customers?id=eq.\(id)"
        try await api.patch(endpoint: endpoint, body: ["is_archived": false])
    }
    
}
