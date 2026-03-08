//
//  RegistrationViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import Foundation
import SwiftUI

@Observable
class RegistrationViewModel {
    
    var loginViewModel : LoginViewModel
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
    }
    
    // Keep model encapsulate for view
    private var model : RegistrationModel = RegistrationModel()
    var firstName : String {
        get { model.firstName }
        set { model.firstName = newValue }
    }
    var lastName : String {
        get { model.lastName }
        set { model.lastName = newValue }
    }
    var email : String {
        get { model.email }
        set { model.email = newValue }
    }
    var password : String {
        get { model.password }
        set { model.password = newValue }
    }
    var confirmPassword : String {
        get { model.confirmPassword }
        set { model.confirmPassword = newValue }
    }
    
    var isFormValid : Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        email.contains("@") &&
        email.contains(".") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
     
    var emailErrorMessage : String? {
        email.isEmpty || (email.contains("@") && email.contains(".")) ? nil : "Please enter a valid email."
    }
    var passwordErrorMessage : String? {
        password.isEmpty || password.count >= 6 ? nil : "Password must be at least 6 characters."
    }
    var confirmPasswordErrorMessage : String? {
        confirmPassword.isEmpty || confirmPassword == password ? nil : "Passwords do not match."
    }
    
    // MARK: -
    // MARK: -
    func registerUser(){
        if isFormValid {
            loginViewModel.path.removeAll()
        } else {
            
        }
    }
    
}
