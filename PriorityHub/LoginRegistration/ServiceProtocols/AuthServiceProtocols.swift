//
//  AuthServiceProtocols.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 5/8/26.
//

import Foundation
import FirebaseAuth

protocol authServiceLoginProtocol {
    func login(withEmail email : String, password : String) async throws -> AuthDataResult?
}

protocol authServiceRegistrationProtocol {
    func userRegistration(withEmail email: String, password: String, firstName: String, lastName: String, ) async throws
}

protocol authServiceForgotPasswordProtocol {
    func resetPasswordWithEmail(withEmail email:String) async throws
}
