//
//  ContentView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 13.01.2026.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var auth :AuthViewModel
    var body: some View {
        VStack {
            Button("Logout") {
                Task {
                    await auth.signOut()
                }
            }
        }
        .padding()
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
