//
//  ProfileService.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 17.01.2026.
//

import Foundation

class ProfileService {
    
    
    func upsertProfile(profile: Profile) async throws{
        
        let profileRequest = profile.toRequest()
        
        try await SupabaseProvider.client
            .from("profiles")
            .upsert(profileRequest)
            .execute()
    }
}
