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
}
//MARK: - will set and get first time app launch status
func setIsFirstTimeLaunchedApp (status : Bool) {
    UserDefaults.standard.set(status, forKey: PREFERENCE_KEY.isFirstTimeLaunchedApp)
    UserDefaults.standard.synchronize()
}
func getIsFirstTimeLaunchedApp() -> Bool {
    return UserDefaults.standard.bool(forKey: PREFERENCE_KEY.isFirstTimeLaunchedApp)
}
//MARK: - set user loghedIn status
func setUserLoggedinStatus(status : Bool) {
    UserDefaults.standard.set(status, forKey: PREFERENCE_KEY.isUserLoggedIn)
    UserDefaults.standard.synchronize()
}
func getUserLoggedinStatus() -> Bool {
    return UserDefaults.standard.bool(forKey: PREFERENCE_KEY.isUserLoggedIn)
}
