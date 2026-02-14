//
//  Customer.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 29.01.2026.
//

import Foundation

struct Customer: Identifiable{
    let id: UUID
    let createdAt: Date?
    let userId: UUID
    var companyName: String
    var contactName: String?
    var phone: String?
    var email: String?
    var adress: String?
    var note: String?
    var isArchived: Bool
    
    init(from response: CustomerResponse) {
        self.id = response.id
        self.createdAt = response.created_at
        self.userId = response.user_id
        self.companyName = response.company_name
        self.contactName = response.contact_name
        self.phone = response.phone
        self.email = response.email
        self.adress = response.adress
        self.note = response.note
        self.isArchived = response.is_archived
    }
    
    init(id: UUID, userId: UUID, companyName: String, contactName: String? = nil, phone: String? = nil, email: String? = nil, adress: String? = nil, note: String? = nil, isArchived: Bool = false) {
        self.id = id
        self.createdAt = nil
        self.userId = userId
        self.companyName = companyName
        self.contactName = contactName
        self.phone = phone
        self.email = email
        self.adress = adress
        self.note = note
        self.isArchived = isArchived
    }
    
    func toRequest() -> CustomerRequest {
        CustomerRequest(id: self.id, company_name: self.companyName, contact_name: self.contactName, phone: self.phone, email: self.email, adress: self.adress, note: self.note, is_archived: self.isArchived)
    }
}

struct CustomerResponse: Decodable {
    let id: UUID
    let created_at: Date
    let user_id: UUID
    let company_name: String
    let contact_name: String?
    let phone: String?
    let email: String?
    let adress: String?
    let note: String?
    let is_archived: Bool
    
}

struct CustomerRequest: Encodable{
    let id: UUID?
    let company_name: String
    let contact_name: String?
    let phone: String?
    let email: String?
    let adress: String?
    let note: String?
    let is_archived: Bool
}
