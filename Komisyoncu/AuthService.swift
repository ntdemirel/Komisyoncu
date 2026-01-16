//
//  AuthService.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 16.01.2026.
//

import Foundation
import Supabase

class AuthService {
    
    
    
    func signUp(email: String, password: String) async throws -> AuthResponse {
        let response = try await SupabaseProvider.client.auth.signUp(email: email, password: password)
        return response
    }
    
    func signIn(email: String, password: String) async throws -> Session{
        let session = try await SupabaseProvider.client.auth.signIn(email: email, password: password)
        return session
    }
    
    func signOut() async throws{
        try await SupabaseProvider.client.auth.signOut()
    }
    
    func getCurrentSession() async throws ->Session {
        let session = try await SupabaseProvider.client.auth.session
        return session
    }
    
    func checkProfileExists(userId: UUID) async throws -> Bool {
        
        do {
            let _ = try await SupabaseProvider.client
                .from("profiles")
                .select("id")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
            // eğer sorgu hata fırlatmazsa veri var demektir.
            return true
        }catch let pgError as PostgrestError where pgError.code == "PGRST116" {
            //"PGRST116" single kullandığımızda 0 veya 1 den fazla veri döndüğünde oluşan hata kodu.
            return false
        } catch {
            throw error
        }

    }
    
}
