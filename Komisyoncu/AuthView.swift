//
//  AuthView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 13.01.2026.
//

import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject private var auth: AuthViewModel
    

    @State private var isRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(isRegister ? "Create Account" : "Sign In")
                    .font(.title2).bold()

                TextField("Email", text: $auth.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $auth.password)
                    .textFieldStyle(.roundedBorder)

                if let msg = auth.errorMessage {
                    Text(msg)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button {
                    Task {
                        if isRegister {
                            await auth.signUp()
                        } else {
                            await auth.signIn()
                        }
                    }
                } label: {
                    if auth.isLoading {
                        ProgressView()
                    } else {
                        Text(isRegister ? "Register" : "Login")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(auth.email.isEmpty || auth.password.isEmpty || auth.isLoading)

                Button(isRegister ? "Already have an account? Sign In" : "No account? Register") {
                    isRegister.toggle()
                    auth.errorMessage = nil
                }
                .font(.footnote)

                Spacer()
            }
            .padding()
            .navigationTitle("Komisyoncu")
            
        }
    }
}
#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
