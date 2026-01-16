//
//  RootView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 13.01.2026.
//

import Foundation
import SwiftUI
import Supabase

struct RootView: View {
    
    @StateObject private var  auth = AuthViewModel()
    

    var body: some View {
        
        Group {
            switch auth.authState {
            case .splash:
                SplashView()
                    .environmentObject(auth)
            case .unauthenticated:
                AuthView()
                    .environmentObject(auth)
            case .authenticated(let needsProfile):
                if needsProfile {
                    CompleteProfileView()
                        .environmentObject(auth)
                }else {
                    MainView()
                        .environmentObject(auth)
                }
            }
        }
    }
}
