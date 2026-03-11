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
            VStack(alignment: .leading) {
                TextField("EMAIL",text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.go)
                    .onSubmit { viewModel.resetPassword() }
                
                if let errorMessage = viewModel.emailErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.red)
                }
            }.animation(.default, value: viewModel.emailErrorMessage)
            
              
            Button(action:{
                viewModel.resetPassword()
            },label: {
                Text("RESET_PASSWORD")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isValidEmail)
            
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
}
// MARK: - View Specific Helper
private enum Field : Hashable {
    case email
}
#Preview {
    ForgotPasswordView(viewModel: ForgotPasswordViewModel(loginViewModel: LoginViewModel()))
}
