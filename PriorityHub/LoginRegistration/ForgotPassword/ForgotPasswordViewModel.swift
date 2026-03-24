//
//  ForgotPasswordViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/6/26.
//

import Foundation
import SwiftUI
import FirebaseAuth

@Observable
@MainActor
class ForgotPasswordViewModel {
    
    // Here we create object for parent class- for pop to root view from navigation stack
    // when resetPassword APT get success response.
    var loginViewModel : LoginViewModel
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
    }
    
    // Keeping encapsulated to model for view
    private var model = ForgotPasswordModel()
    var email : String {
        get { model.email }
        set { model.email = newValue }
    }
    var isValidEmail : Bool {
        email.contains("@") &&
        email.contains(".")
    }
    var emailErrorMessage : String? {
        email.isEmpty || (email.contains("@") && email.contains(".")) ? nil : String(localized: "PLEASE_ENTER_VALID_EMAIL")
    }
    
    var resetLinkSent : Bool = false
    
    // MARK: -
    // MARK: - API Call
    func resetPassword() async {
        if isValidEmail {
            AlertManager.shared.isShowGlobalLoading = true
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                resetLinkSent = true
                AlertManager.shared.isShowGlobalLoading = false
            } catch {
                AlertManager.shared.showAlert(title: String(localized: "ALERT!"), message: loginViewModel.authError(error: error))
            }
        } else {
            
        }
    }
    func redirectToLoginPage(){
        loginViewModel.path.removeAll()
    }
}
