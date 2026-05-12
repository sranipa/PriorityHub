//
//  FirebaseAuthServices.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 5/8/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class firebaseAuthServices : authServiceLoginProtocol, authServiceRegistrationProtocol, authServiceForgotPasswordProtocol {
    
    func userRegistration(withEmail email: String, password: String, firstName: String, lastName: String) async throws {
        
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
        
    }
    
    func login(withEmail email: String, password : String) async throws -> FirebaseAuth.AuthDataResult? {
        let email = email.trimmingCharacters(in: .whitespaces)
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func resetPasswordWithEmail(withEmail email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
