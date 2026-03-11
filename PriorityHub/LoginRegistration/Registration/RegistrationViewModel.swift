//
//  RegistrationViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
        email.isEmpty || (email.contains("@") && email.contains(".")) ? nil : String(localized: "PLEASE_ENTER_VALID_EMAIL")
    }
    var passwordErrorMessage : String? {
        password.isEmpty || password.count >= 6 ? nil : String(localized:"PASSWORD_MUST_BE_AT_LEAST_6_CHARACTERS")
    }
    var confirmPasswordErrorMessage : String? {
        confirmPassword.isEmpty || confirmPassword == password ? nil : String(localized:"PASSWORDS_DO_NOT_MATCH")
    }
    
    // MARK: -
    // MARK: -
    func registerUser() async {
        if isFormValid {
            AlertManager.shared.isShowGlobalLoading = true
            do {
                // 1. Create User in Auth
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = authResult.user.uid
                
                // 2. Save additional details to Firestore
                let db = Firestore.firestore()
                try await db.collection(COLLECTION.USERS).document(uid).setData([
                    PARAMS.FIRST_NAME : firstName,
                    PARAMS.LAST_NAME : lastName,
                    PARAMS.EMAIL : email,
                    PARAMS.CREATED_AT : Timestamp(date: Date())
                ])
                
                try await authResult.user.sendEmailVerification()
                
                loginViewModel.path.removeAll() // Pop to root view.
                AlertManager.shared.isShowGlobalLoading = false
                AlertManager.shared.showAlert(title: String(localized:"SUCCESS"), message: String(localized: "THANKS_FOR_REGISTERING_ACCOUNT"))
            } catch {
                AlertManager.shared.isShowGlobalLoading = false
                AlertManager.shared.showAlert(title: String(localized:"ALERT!"), message: loginViewModel.authError(error: error))
            }
        } else {
            print("")
        }
    }
    
}
