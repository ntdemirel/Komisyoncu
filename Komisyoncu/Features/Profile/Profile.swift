//
//  Profile.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 17.01.2026.
//

import Foundation

struct Profile: Decodable, Identifiable {
    let id: UUID
    let created_at: Date
    var company_name: String
    var full_name: String
    var phone: String?
    

}

struct ProfileUpsert: Encodable {
    let id: UUID
    let company_name: String
    let phone: String?
    let full_name: String
    

}
