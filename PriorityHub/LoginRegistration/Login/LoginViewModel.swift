//
//  LoginViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import Foundation
import SwiftUI
import Combine

@Observable class LoginViewModel {
    
    var path = [LoginRoute]() // This is source of truth for Navigation
    
    // Private - Encapsulation. Kept model hidden from view
    private var model = LoginModel()
    var email : String {
        get { model.email }
        set { model.email = newValue }
    }
    var password : String {
        get { model.password }
        set { model.password = newValue }
    }
    
    //MARK: -
    //MARK: - Validation
    var isFormValid : Bool {
        email.contains("@") &&
        email.contains(".") &&
        password.count >= 6
    }
    var emailErrorMessage : String? {
        email.isEmpty || (email.contains("@") && email.contains(".")) ? nil : "Please enter a valid email."
    }
    var passwordErrorMessage : String? {
        password.isEmpty || password.count >= 6 ? nil : "Password must be at least 6 characters."
    }
    
    //MARK: -
    //MARK: - API Call
    func login() {
        if isFormValid {
             
        } else {
            
        }
    }
}
