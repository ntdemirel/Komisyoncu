//
//  SupabaseClientProvider.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 13.01.2026.
//

import Foundation
import Supabase

enum AppConfig {
    
    static var supabaseURL : URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: raw)
        else {
            fatalError("Missing SUPABASE_URL in Info.plist")
        }
        return url
    }
    
    static var supabaseAnonKey: String {
        
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("Missing SUPABASE_ANON_KEY in Info.plist")
        }
        return key
    }
    
}

enum SupabaseProvider {
    static let client = SupabaseClient(supabaseURL: AppConfig.supabaseURL, supabaseKey: AppConfig.supabaseAnonKey)
}
