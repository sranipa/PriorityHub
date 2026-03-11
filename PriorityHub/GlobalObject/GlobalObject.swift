//
//  GlobalObject.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/9/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
class GlobalObject {
    // Login Status
    var isUserLoggedIn : Bool = false
    var currentUser : UserProfileModel?
    private var authStateHandler : AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen to auth handler for Login/Logout/AppLaunch
        // - It will handle user is loggedIn or not
        DispatchQueue.main.async {
            self.checkFirstLaunch()
            self.setupAuthListener()
        }
    }
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    //MARK: - Check app is launching first time
    private func checkFirstLaunch() {
        let isFirstTimeLaunched : Bool = getIsFirstTimeLaunchedApp()
        if !isFirstTimeLaunched {
            try? Auth.auth().signOut()
            setIsFirstTimeLaunchedApp(status: true)
        }
    }
    //MARK: - setting listener to check user loggeIn and Logout
    private func setupAuthListener() {
        self.authStateHandler = Auth.auth().addStateDidChangeListener({[weak self] _, user in
            
            guard let self = self else { return }
            
            if let firebaseUser = user, firebaseUser.isEmailVerified {
                self.isUserLoggedIn = true
                Task {
                    await self.getUserProfileDetails(uid: firebaseUser.uid)
                }
            } else {
                self.isUserLoggedIn = false
                self.currentUser = nil
            }
        })
    }
    //MARK: - Fetch User data from firestore and save locally - when loggedIn
    private func getUserProfileDetails(uid: String) async {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection(COLLECTION.USERS).document(uid).getDocument()
            
            if let profile = try? snapshot.data(as: UserProfileModel.self) {
                await MainActor.run {
                    self.currentUser = profile
                }
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
    }
}
