//
//  ProfileService.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 17.01.2026.
//

import Foundation

class ProfileService {
    
    
    func upsertProfile(profileModel: ProfileModel) async throws{
        
        let profile = ProfileUpsert(
            id: profileModel.id,
            company_name: profileModel.companyName,
            phone: profileModel.phone,
            full_name: profileModel.fullName)
        
        try await SupabaseProvider.client
            .from("profiles")
            .upsert(profile)
            .execute()
        
    }
}
