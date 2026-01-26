//
//  ValidationHelper.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 25.01.2026.
//

import Foundation

enum ValidationHelper {
    
    //MARK: - MAIL VALIDATON
    
    static func isValidEmail(_ email: String) -> Bool {
        
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else{return false}
        
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }
        
        let domain = parts[1]
        guard !parts[0].isEmpty, !domain.isEmpty else { return false }
        guard domain.contains(".") else { return false }
        
        
        return true
    }
    
    
    //MARK: - PASSWORD VALIDATION
    
    static func isValidPassword(_ password: String) -> Bool {
        hasMinLength(password) &&
        hasUppercase(password) &&
        hasLowercase(password) &&
        hasNumber(password)
    }
    
    static func hasMinLength(_ password: String, min: Int = 8) -> Bool {
        password.count >= min
    }
    
    static func hasUppercase(_ password: String) -> Bool {
        password.contains(where: { $0.isUppercase })
    }
    
    static func hasLowercase(_ password: String) -> Bool {
        password.contains(where: { $0.isLowercase })
    }
    
    static func hasNumber(_ password: String) -> Bool {
        password.contains(where: { $0.isNumber })
    }
    
    
    enum PasswordRule: CaseIterable {
        case minLenght
        case uppercase
        case lowercase
        case number
        
        var message: String {
            switch self {
            case .minLenght:
                return "At least 8 characters"
            case .uppercase:
                return "One uppercase letter"
            case .lowercase:
                return "One lowercase letter"
            case .number:
                return "One number"
            }
        }
        
        func isSatisfied (password: String) -> Bool {
            switch self {
            case .minLenght:
                return hasMinLength(password)
            case .uppercase:
                return hasUppercase(password)
            case .lowercase:
                return hasLowercase(password)
            case .number:
                return hasNumber(password)
            }
        }
        
    }
    
    
    
}
