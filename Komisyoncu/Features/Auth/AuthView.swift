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
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        ScrollView(){
            
            VStack(spacing: 0){
                
                headerSection
                .padding(.top, 48)
                
                formSection
                .padding(.top, 48)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.appBackground)
        .animation(.easeInOut, value: auth.errorMessage)
    }
    
    //MARK: - HEADER SECTION
    private var headerSection: some View {
        VStack(spacing: 24){
            //Icon
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appPrimary)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundStyle(.white)
                
            }
            .frame(width: 80,height: 80)
            .shadow(color: Color.appPrimary.opacity(0.15), radius: 12, x: 0, y: 8)
            
            //Titles
            VStack{
                Text("Komisyoncu")
                    .font(.system(size: 26))
                    .fontWeight(.semibold)
                Text(isRegister ? "Create your account." : "Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.85))
            }
        }
    }
    
    //MARK: - FORM SECTION
    private var formSection: some View {
        VStack(spacing: 16){
            
            //Email
            VStack(alignment: .leading, spacing: 8){
                Label("Email", systemImage: "envelope")
                    .font(.system(size: 13, weight: .medium))
                TextField("Enter your email", text: $auth.email)
                    .textFieldStyle(AppTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
            }
            
            //Password
            VStack(alignment: .leading, spacing: 8){
                Label("Password", systemImage: "lock")
                    .font(.system(size: 13, weight: .medium))
                SecureField("*******", text: $auth.password)
                    .textFieldStyle(AppTextFieldStyle())
                    .textContentType(isRegister ? .newPassword : .password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
            }
            //Register Password Rules
            if isRegister {
                passwordRuleRows
            }
            //error
            if let errorMessage = auth.errorMessage {
                HStack{
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .transition(.scale.combined(with: .opacity))
            }
            
            //Buttons
            VStack(spacing: 24){
                
                //Action Button
                Button{
                    submitForm()
                }label: {
                    if auth.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isRegister ? "Create Account" : "Sign In")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.black)
                .cornerRadius(8)
                .disabled(auth.isLoading)
                
                //Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.appBorder)
                        .frame(height: 1)
                    Text("or")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                    Rectangle()
                        .fill(Color(red: 229/255, green: 231/255, blue: 235/255))
                        .frame(height: 1)
                }
                
                //Secondary Button
                Button{
                    changeAuthMethod()
                }label: {
                    Text(isRegister ? "Sign In" : "Create Account")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.clear)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .disabled(auth.isLoading)
            }
            .padding(.top,16)
        }

    }
    
    
    private func submitForm() {
        focusedField = nil
        Task {
            if isRegister {
                await auth.signUp()
            } else {
                await auth.signIn()
            }
        }
    }
    
    private func changeAuthMethod() {
        isRegister.toggle()
        auth.errorMessage = nil
        focusedField = nil
    }
    
    
    private var passwordRuleRows: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(ValidationHelper.PasswordRule.allCases, id: \.self) { rule in
                passwordRuleRow(
                    text: rule.message,
                    isValid: rule.isSatisfied(password: auth.password)
                )
            }
        }
    }
    
    @ViewBuilder
    private func passwordRuleRow(text: String, isValid: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .appSuccess : .appTextTertiary)
                .font(.system(size: 12))

            Text(text)
                .font(.caption)
                .foregroundColor(isValid ? .appSuccess : .gray)
            Spacer()
        }
    }
    
}






#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
