//
//  ProfileViewModel.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 17.01.2026.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject{
    
    @Published var companyName: String = ""
    @Published var phone: String = ""
    @Published var fullName: String = ""
    
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userId: UUID
    private let profileService : ProfileService
    
    
    init(userId: UUID, service: ProfileService = ProfileService()) {
        self.userId = userId
        self.profileService = service
    }
    
    
    
    var isFormValid: Bool {
        !companyName.trimmingCharacters(in: .whitespaces).isEmpty && !fullName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    func upsertProfile() async -> ProfileModel?{
        
        isLoading = true
        errorMessage = nil
        
        defer {isLoading = false }
        
        let profileModel = ProfileModel(
            id: userId,
            companyName: companyName,
            phone: phone,
            fullName: fullName,
            createdAt: nil
        )
        
        do {
            try await profileService.upsertProfile(profileModel: profileModel)
            return profileModel
        } catch {
            print(error.localizedDescription)
            errorMessage = "Someting went wrong. Please try again later."
            return nil
        }
        
    }
    
    
}

struct ProfileModel: Identifiable {
    let id: UUID
    var companyName: String
    var phone: String
    var fullName: String
    var createdAt: Date?
}
