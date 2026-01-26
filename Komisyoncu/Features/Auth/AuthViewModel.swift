//
//  AuthViewModel.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 13.01.2026.
//

import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .splash
    
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var authService = AuthService()
    private(set) var currentUserId: UUID?
    
    init(service: AuthService = AuthService()){
        self.authService = service // Test için
    }
    
    var isSignInFormValid: Bool {
        ValidationHelper.isValidEmail(email) && !password.isEmpty
    }
    var isSignUpFormValid: Bool {
        ValidationHelper.isValidEmail(email) &&  ValidationHelper.isValidPassword(password)
    }
    
    func checkAuthStatus(delay: UInt64) async {
        async let minDelay: Void = {
            try? await Task.sleep(nanoseconds: delay)
        }()
        // ilk açılıştaki oturum kontrolü
        
        do {
            let session = try await authService.getCurrentSession()
            currentUserId = session.user.id
            let hasProfile = try await authService.checkProfileExists(userId: session.user.id)
            await (minDelay)
            authState = .authenticated(needsProfile: !hasProfile)
        } catch  {
            await (minDelay)
            authState = .unauthenticated
        }
    }
    
    func signUp() async {
        
        if !isSignInFormValid {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer{ isLoading = false} // signUp fonskiyonundan çıkıldığında  clouser içi çalışıyor.
        
        do {
            let result = try await authService.signUp(email: email, password: password)
            //Email Confirm result'a user gelir fakat session nil olur.
            if result.session == nil {
                errorMessage = "A confirmation email has been sent."
            }
        }catch {
            errorMessage = error.localizedDescription
        }
    }
    

    
    func signIn() async {
        if !isSignInFormValid {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        isLoading = true
        errorMessage = nil
        
        defer {isLoading = false}
        
        do {
            //Giriş kontrolü + profil kayıt kontrolü
            
            let session = try await authService.signIn(email: email, password: password)
            currentUserId = session.user.id
            let hasProfile = try await authService.checkProfileExists(userId: session.user.id)
            
            authState = .authenticated(needsProfile: !hasProfile)
            
        }catch {
            
            //https://supabase.com/docs/guides/auth/debugging/error-codes
            if let authError = error as? AuthError {
                switch authError.errorCode {
                case .emailNotConfirmed:
                    errorMessage = "Email not confirmed. Please check your inbox."
                default:
                    errorMessage = authError.localizedDescription
                }
            }else {
                //SignIn error ve checkProfilExist error.
                errorMessage = "Some thing wrong. Please try again later."
                print("error cast failed: \(error)")
            }
        }
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        defer {isLoading = false}
        
        do {
            try await authService.signOut()
            currentUserId = nil
            authState = .unauthenticated
            email = ""
            password = ""
        } catch  {
            errorMessage = error.localizedDescription
        }
    }
    
    func profileCompleted() async {
        authState = .authenticated(needsProfile: false)
    }
}

enum AuthState {
    case splash
    case unauthenticated
    case authenticated(needsProfile: Bool)
    
}
