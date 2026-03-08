//
//  ForgotPasswordViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/6/26.
//

import Foundation
import SwiftUI

@Observable
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
        email.isEmpty || (email.contains("@") && email.contains(".")) ? nil : "Please enter a valid email."
    }
    
    // MARK: -
    // MARK: - API Call
    func resetPassword() {
        if isValidEmail {
            loginViewModel.path.removeAll()
            print("Reset Password Called")
        } else {
            
        }
    }
}
