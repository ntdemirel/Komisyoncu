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
                
            case .unauthenticated:
                AuthView()
                
            case .authenticated(let needsProfile):
                if needsProfile {
                    if let userId = auth.currentUserId {
                        CompleteProfileView(userId: userId)
                    }else {
                        AuthView()
                    }
                }else {
                    CustomerListView()
                }
            }
        }.environmentObject(auth)
    }
}
