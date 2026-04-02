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
    
    var selectedTab : Int = 1
    
    // Login Status
    var isUserLoggedIn : Bool = false
    var currentUser : ProfileModel?
    private var authStateHandler : AuthStateDidChangeListenerHandle?
    var userProfileListener : ListenerRegistration?
    
    init() {
        // Listen to auth handler for Login/Logout/AppLaunch
        // - It will handle user is loggedIn or not
        DispatchQueue.main.async {
            self.checkFirstLaunch()
            self.setupAuthListener()
        }
    }
    deinit {
//        if let handler = authStateHandler {
//            Auth.auth().removeStateDidChangeListener(handler)
//        }
//        if let userListener = userProfileListener {
//            userListener.remove()
//        }
    }
    //MARK: - Check app is launching first time
    private func checkFirstLaunch() {
        let isFirstTimeLaunched : Bool = getIsFirstTimeLaunchedApp()
        if !isFirstTimeLaunched {
            try? Auth.auth().signOut()
            setIsFirstTimeLaunchedApp(status: true)
            setUserLoggedIn(status: false)
        }
    }
    //MARK: - setting listener to check user loggeIn and Logout
    private func setupAuthListener() {
        self.authStateHandler = Auth.auth().addStateDidChangeListener({[weak self] _, user in
            
            guard let self = self else { return }
            
            if let firebaseUser = user, firebaseUser.isEmailVerified {
                self.isUserLoggedIn = true
                setUserLoggedIn(status: true)
                Task {
                    await self.getUserProfileDetails(uid: firebaseUser.uid)
                }
            } else {
                self.isUserLoggedIn = false
                setUserLoggedIn(status: false)
                self.currentUser = nil
                self.selectedTab = 1
                removeFirebaseUserID()
            }
        })
    }
    //MARK: - Fetch User data from firestore and save locally - when loggedIn
    private func getUserProfileDetails(uid: String) async {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection(COLLECTION.USERS).document(uid).getDocument()
            
            if let profile = try? snapshot.data(as: ProfileModel.self) {
                await MainActor.run {
                    self.currentUser = profile
                    setFirebaseUserID(userId: self.currentUser?.uid ?? "")
                    self.addListnerForUserProfileData()
                }
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
    }
    
    func addListnerForUserProfileData() {
        let db = Firestore.firestore()
        if let uid = currentUser?.uid, userProfileListener == nil {
            userProfileListener?.remove()
            // 1. Process data on the background thread (from Firestore)
            userProfileListener = db.collection(COLLECTION.USERS).document(uid).addSnapshotListener { snapshot, error in
                if let snapshot = snapshot {
                    guard let data = try? snapshot.data(as: ProfileModel.self) else { return }
                    // 2. Hop to the MainActor to update the @Observable property
                    Task {
                        @MainActor in
                        self.currentUser = data
                        setFirebaseUserID(userId: self.currentUser?.uid ?? "")
                    }
                } else {
                    print("Global Object: Error --> \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
}
