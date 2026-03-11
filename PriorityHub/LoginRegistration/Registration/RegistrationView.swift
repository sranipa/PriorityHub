//
//  RegistrationView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import SwiftUI

struct RegistrationView: View {
    
    @State var viewModel : RegistrationViewModel // Injected
    @FocusState private var focusedField : Field?
    
    var body: some View {
        ScrollView{
            VStack(spacing:20){
                firstNameView
                
                lastNameView
                
                emailView
                
                passwordView
                
                confirmPasswordView
                
                submitButtonView
            }
            .padding()
        }
        .navigationTitle("REGISTER")
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            viewModel.loginViewModel.email = ""
            viewModel.loginViewModel.password = ""
        }
    }
    private var firstNameView : some View {
        TextField("FIRST_NAME", text: $viewModel.firstName)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .focused($focusedField, equals: .firstName)
            .submitLabel(.next)
            .onSubmit { focusedField = .lastName }
    }
    private var lastNameView : some View {
        TextField("LAST_NAME", text: $viewModel.lastName)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .focused($focusedField, equals: .lastName)
            .submitLabel(.next)
            .onSubmit { focusedField  = .email }
    }
    private var emailView : some View {
        VStack(alignment: .leading) {
            TextField("EMAIL",text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            
            if let errorMessage = viewModel.emailErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }.animation(.default, value: viewModel.emailErrorMessage)
    }
    
    private var passwordView : some View {
        VStack(alignment: .leading) {
            SecureField("PASSWORD", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
            
            if let errorMessage = viewModel.passwordErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }.animation(.default, value: viewModel.passwordErrorMessage)
    }
    private var confirmPasswordView : some View {
        VStack(alignment: .leading) {
            SecureField("CONFIRM_PASSWORD", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit { focusedField = .none }
            
            if let errorMessage = viewModel.confirmPasswordErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }.animation(.default, value: viewModel.confirmPasswordErrorMessage)
    }
    private var submitButtonView : some View {
        Button(action: {
            focusedField = nil
            Task {
                await viewModel.registerUser()
            }
        }, label: {
            Text("SUBMIT")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.isFormValid)
    }
}
// MARK: -
// MARK: - View Specific helper
private enum Field : Hashable {
    case firstName
    case lastName
    case email
    case password
    case confirmPassword
}


#Preview {
    RegistrationView(viewModel: RegistrationViewModel(loginViewModel: LoginViewModel()))
}
