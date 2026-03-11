//
//  ForgotPasswordView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/6/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @State var viewModel:ForgotPasswordViewModel // Dependency Injecation - Here we Injected
    @FocusState private var focusedField : Field?
    
    var body: some View {
        VStack(spacing:20){
            
            if viewModel.resetLinkSent {
                viewForMessage
            } else {
                viewForEmail
                  
                viewForResetPasswordButton
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("FORGOT_PASSWORD")
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            viewModel.loginViewModel.email = ""
            viewModel.loginViewModel.password = ""
        }
    }
    var viewForMessage : some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.green)
                .font(.largeTitle)
            
            Text("RESET_PASSWORD_LINK_HAS_BEEN_SENT_ON_YOUR_EMAIL")
                .font(.subheadline)
            
            Button {
                viewModel.redirectToLoginPage()
            } label: {
                Text("LOGIN_HERE")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
    var viewForEmail : some View {
        VStack(alignment: .leading) {
            TextField("EMAIL",text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .focused($focusedField, equals: .email)
                .submitLabel(.go)
                .onSubmit { resetPassword() }
            
            if let errorMessage = viewModel.emailErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }.animation(.default, value: viewModel.emailErrorMessage)
    }
    var viewForResetPasswordButton : some View {
        Button(action:{
            resetPassword()
        },label: {
            Text("RESET_PASSWORD")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.isValidEmail)
    }
    func resetPassword() {
        Task {
            await viewModel.resetPassword()
        }
    }
}
// MARK: - View Specific Helper
private enum Field : Hashable {
    case email
}
#Preview {
    ForgotPasswordView(viewModel: ForgotPasswordViewModel(loginViewModel: LoginViewModel()))
}
