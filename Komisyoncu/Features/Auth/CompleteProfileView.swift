//
//  CompleteProfileView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 14.01.2026.
//

import SwiftUI


struct CompleteProfileView: View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var vm: ProfileViewModel
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case companyName, fullName, phone
    }
    
    init(userId:UUID) {
        _vm = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }
    
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                .padding(.top, 48)
                                
                formSection
                .padding(.top, 48)
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground)
        .animation(.easeInOut, value: vm.errorMessage)
    }
    
    //MARK: - HEADER SECTION
    private var headerSection: some View {
        VStack(spacing: 24){
            //Icon
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appPrimary)
                Image(systemName: "person.fill.badge.plus")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundStyle(.white)
                
            }
            .frame(width: 80,height: 80)
            .shadow(color: Color.appPrimary.opacity(0.15), radius: 12, x: 0, y: 8)
            
            //Titles
            VStack{
                Text("Complete Your Profile")
                    .font(.system(size: 26))
                    .fontWeight(.semibold)
                Text("Just a few details to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.85))
            }
        }

    }
    
    //MARK: - FORM SECTION
    private var formSection: some View {
        VStack(spacing: 16){
            
            //Company Name
            VStack(alignment: .leading,spacing: 8){
                Label("Company Name", systemImage: "building.2")
                    .font(.system(size: 13, weight: .medium))
                TextField("Acme Inc.",text: $vm.companyName)
                    .textFieldStyle(AppTextFieldStyle())
                    .focused($focusedField, equals: .companyName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .fullName
                    }
            }
            
            //Full Name
            VStack(alignment: .leading,spacing: 8){
                Label("Full Name", systemImage: "person")
                    .font(.system(size: 13, weight: .medium))
                TextField("John Doe",text: $vm.fullName)
                    .textFieldStyle(AppTextFieldStyle())
                    .focused($focusedField, equals: .fullName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .phone
                    }
            }
            
            //Phone
            VStack(alignment: .leading, spacing: 8){
                HStack {
                    Label("Phone Number", systemImage: "phone")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text("Optional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                TextField("534-871-94-35",text: $vm.phone)
                    .textFieldStyle(AppTextFieldStyle())
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .phone)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
            }
            
            //Error
            if let errorMessage = vm.errorMessage {
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
            VStack(spacing: 12){
                
                //Countinue Button
                Button{
                    Task{
                        let result = await vm.upsertProfile()
                        if result != nil {
                            await auth.profileCompleted()
                        }
                    }
                }label: {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Countinue")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(vm.isFormValid ? Color.appPrimary : Color.appTextTertiary)
                .cornerRadius(8)
                .disabled(vm.isLoading || !vm.isFormValid)
                
                //SignOut Button
                Button{
                    Task{
                        await auth.signOut()
                    }
                }label: {
                    Text("Sign Out")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .disabled(vm.isLoading )
            }
            .padding(.top, 12)
        }

    }
}



#Preview {
    CompleteProfileView(userId: UUID())
        .environmentObject(AuthViewModel())
}

