//
//  MockAuthServices.swift
//  PriorityHubTests
//
//  Created by Sapana Bhorania on 5/8/26.
//

import Foundation
import FirebaseAuth
@testable import PriorityHub

class MockAuthServices : authServiceLoginProtocol, authServiceRegistrationProtocol, authServiceForgotPasswordProtocol {
    
    var isUserRegistered : Bool = false
    var isError : Bool = false
    
    func login(withEmail email: String, password : String) async throws -> FirebaseAuth.AuthDataResult? {
        return nil
    }
    func resetPasswordWithEmail(withEmail email: String) async throws {
        print("Mock ResetPasswordLink Sent To Email")
    }
    func userRegistration(withEmail email: String, password: String, firstName: String, lastName: String) async throws {
        if isError {
            throw NSError(domain: "Auth", code: 17007)
        } else {
            isUserRegistered = true
            print("Registration Successfully")
        }
    }
}
// Mock Test Class
class mockAlertManager : alertManagerProtocol {
    var isShowGlobalLoading: Bool = false
}
