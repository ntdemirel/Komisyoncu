//
//  SplashView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 16.01.2026.
//

import SwiftUI

struct SplashView: View {

    @EnvironmentObject private var auth :AuthViewModel
    private let splashSeconds: Double = 1.5
    private var splashNanoseconds: UInt64 {
        UInt64(splashSeconds * 1_000_000_000)
    }
    var body: some View {
        
        VStack {
            Text("Merhaba Komisyocu")
                .font(.largeTitle)
        }
        .task {
            
            await auth.checkAuthStatus(delay: splashNanoseconds)
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthViewModel())
}
