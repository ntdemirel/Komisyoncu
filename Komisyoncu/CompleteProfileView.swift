//
//  ComplateProfileView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 14.01.2026.
//

import SwiftUI

struct CompleteProfileView: View {
    
    @EnvironmentObject private var auth: AuthViewModel
    var body: some View {
        VStack{
            Text("Bilgi Doldurma ekranın")
            Button("Logout") {
                Task {
                    await auth.signOut()
                }
            }
        }
    }
}

#Preview {
    //CompleteProfileView(onCompleted: {})
}
