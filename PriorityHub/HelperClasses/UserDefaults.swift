//
//  UserDefaults.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/10/26.
//

import Foundation

struct PREFERENCE_KEY {
    static let isFirstTimeLaunchedApp : String = "isFirstTimeLaunchedApp"
    static let isUserLoggedIn : String = "isUserLoggedIn"
    static let firebaseUserId : String = "firebaseUserId"
}
//MARK: - will set and get first time app launch status
func setIsFirstTimeLaunchedApp (status : Bool) {
    UserDefaults.standard.set(status, forKey: PREFERENCE_KEY.isFirstTimeLaunchedApp)
    UserDefaults.standard.synchronize()
}
func getIsFirstTimeLaunchedApp() -> Bool {
    return UserDefaults.standard.bool(forKey: PREFERENCE_KEY.isFirstTimeLaunchedApp)
}
//MARK: - Set, get and remove firebase userID
func setFirebaseUserID (userId : String) {
    UserDefaults.standard.set(userId, forKey: PREFERENCE_KEY.firebaseUserId)
    UserDefaults.standard.synchronize()
}
func getFirebaseUserID() -> String? {
    return UserDefaults.standard.string(forKey: PREFERENCE_KEY.firebaseUserId)
}
func removeFirebaseUserID() {
    UserDefaults.standard.removeObject(forKey: PREFERENCE_KEY.firebaseUserId)
    UserDefaults.standard.synchronize()
}
