//
//  ProfileViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/12/26.
//

import Foundation
import SwiftUI
import FirebaseAuth

@Observable
class ProfileViewModel {
    
    //MARK: - Alert For Logout
    func showAlertForLogout() {
        AlertManager.shared.showAlert(title: String(localized:"LOGOUT"),
                                      message: String(localized:"ARE_YOU_SURE_YOU_WANT_TO_LOGOUT"),
                                      okTitle: String(localized:"LOGOUT"),
                                      isDestructive : true,
                                      okAction: { self.logout() },
                                      cancelTitle: String(localized: "CANCEL"),
                                      cancelAction: {})
    }
    
    //MARK: - Firebase Logout
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            AlertManager.shared.showAlert(title: String(localized: "ALERT!"), message: error.localizedDescription)
        }
    }
}
