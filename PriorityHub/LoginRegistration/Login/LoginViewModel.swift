//
//  LoginViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@Observable
@MainActor
class LoginViewModel {
    
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
        email.isEmpty || (email.contains("@") && email.contains(".")) ? nil : String(localized: "PLEASE_ENTER_VALID_EMAIL")
    }
    var passwordErrorMessage : String? {
        password.isEmpty || password.count >= 6 ? nil : String(localized:"PASSWORD_MUST_BE_AT_LEAST_6_CHARACTERS")
    }
    
    //MARK: -
    //MARK: - API Call
    func login() async {
        if isFormValid {
            AlertManager.shared.isShowGlobalLoading = true
            do {
                let email = email.trimmingCharacters(in: .whitespaces)
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                AlertManager.shared.isShowGlobalLoading = false
                
                if authResult.user.isEmailVerified {
                     print("LoggedIn Successfully!")
                } else {
                    AlertManager.shared.showAlert(title: String(localized:"ALERT!"), message:String(localized:"EMAIL_IS_NOT_VERIFIED_PLEASE_VERIFY_YOUR_EMAIL_FIRST"))
                }
            } catch {
                AlertManager.shared.isShowGlobalLoading = false
                AlertManager.shared.showAlert(title: String(localized:"ALERT!"), message: authError(error: error))
            }
        } else {
            
        }
    }
    func authError(error:Error) -> String {
        // Cast Error to NSError for access error code
        let nsError : NSError = error as NSError
        
        if let errorCode = AuthErrorCode(rawValue: nsError.code) {
            switch errorCode {
            case .invalidEmail:
                return String(localized: "THE_EMAIL_ADDRESS_IS_INVALID")
            case .wrongPassword:
                return String(localized: "INCORRECT_PASSWORD_PLEASE_TRY_AGAIN")
            case .invalidCredential:
                return String(localized: "EMAIL_OR_PASSWORD_ARE_INVALID")
            case .emailAlreadyInUse:
                return String(localized: "AN_ACCOUNT_ALREADY_EXITS_WITH_THIS_EMAIL") 
            case .userNotFound:
                return String(localized: "NO_ACCOUNT_FOUND_WITH_THIS_EMAIL")
            case .networkError:
                return String(localized: "NETWORK_ERROR_PLEASE_CHECK_YOUR_CONNECTION")
            default :
                return String(localized:"AN_UNEXPECTED_ERROR_OCCURED \(nsError.localizedDescription)")
            }
        } else {
            return error.localizedDescription
        }
    }
}
