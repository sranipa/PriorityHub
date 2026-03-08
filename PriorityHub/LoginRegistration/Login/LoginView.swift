//
//  LoginView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import SwiftUI
 
struct LoginView: View {
    
    @State private var viewModel = LoginViewModel()
    @FocusState private var focusedField : Field? // It will handle keyboard flow
    
    var body: some View {
        NavigationStack(path:$viewModel.path) {
            VStack(spacing:20) {
                Text("Login")
                    .font(.title)
                
                viewForEmail
                
                viewForPassword
                
                Button(action : {
                    viewModel.login()
                }, label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Login to your account")
                .disabled(!viewModel.isFormValid)
                 
                NavigationLink(value: LoginRoute.forgotpassword) {
                    Text("Forgot Password?")
                }
                
                Spacer()
                
                viewForRegistration
            }
            .padding()
            .contentShape(Rectangle()) // tells SwiftUI: "Even if there is nothing here, treat this entire rectangular area as a valid tap zone."
            .onTapGesture {
                focusedField = nil
            }
            .navigationDestination(for: LoginRoute.self) { route in
                switch route {
                case .forgotpassword:
                    let vm = ForgotPasswordViewModel(loginViewModel: viewModel)
                    ForgotPasswordView(viewModel: vm)
                case .registration:
                    let vm = RegistrationViewModel(loginViewModel: viewModel)
                    RegistrationView(viewModel: vm)
                }
            }
        }
    }
    private var viewForEmail : some View {
        VStack(alignment: .leading) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next) // Set next button on keyboard
                .onSubmit { focusedField = .password } // on press next it will focus on password
            
            if let errorMessage = viewModel.emailErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }.animation(.default, value: viewModel.emailErrorMessage)
    }
    private var viewForPassword : some View {
        VStack(alignment: .leading) {
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { viewModel.login() }
            
            if let errorMessage = viewModel.passwordErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }.animation(.default, value: viewModel.passwordErrorMessage)
    }
    private var viewForRegistration : some View {
        HStack(spacing:5){
            Text("Don't have an account?")
            
            NavigationLink(value: LoginRoute.registration) {
                Text("Register Here")
            }
        }
    }
}
// MARK: -
// MARK: - View Specific Helper
private enum Field : Hashable {
    case email
    case password
}
enum LoginRoute : Hashable {
    case forgotpassword
    case registration
}
#Preview {
    LoginView()
}
