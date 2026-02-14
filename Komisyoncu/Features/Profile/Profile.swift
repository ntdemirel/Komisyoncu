//
//  Profile.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 17.01.2026.
//

import Foundation

struct Profile: Identifiable {
    let id: UUID
    let createdAt: Date?
    var companyName: String
    var fullName: String
    var phone: String?
    
    init(from response: ProfileResponse){
        self.id = response.id
        self.createdAt = response.created_at
        self.companyName = response.company_name
        self.fullName = response.full_name
        self.phone = response.phone
        
    }
    
    init(id: UUID, companyName: String, fullName: String, phone: String? = nil) {
        self.id = id
        self.companyName = companyName
        self.fullName = fullName
        self.phone = phone
        self.createdAt = nil
    }
    
    func toRequest() -> ProfileRequest {
        ProfileRequest(
            id: id,
            company_name: companyName,
            phone: phone,
            full_name: fullName
        )
    }
}


struct ProfileResponse: Decodable {
    let id: UUID
    let company_name: String
    let phone: String?
    let full_name: String
    let created_at: Date
}

struct ProfileRequest: Encodable {
    let id: UUID
    let company_name: String
    let phone: String?
    let full_name: String
}
