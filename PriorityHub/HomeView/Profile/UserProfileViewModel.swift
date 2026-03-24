//
//  UserProfileViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/13/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
class UserProfileViewModel {

    var uid: String = ""
    var firstName : String = ""
    var lastName : String  = ""
    var userEmail : String = ""
    var isAllowEdit : Bool = false
    var showPopup : Bool = false

    //MARK: - Update User Profile details
    func updateUserDetails() async {
        if isAllowEdit {
            if let uid = Auth.auth().currentUser?.uid, uid == self.uid {
                AlertManager.shared.isShowGlobalLoading = true
                let db = Firestore.firestore()
                let docReference = db.collection(COLLECTION.USERS).document(uid)
                
                let updatedData : [String : Any] = [PARAMS.FIRST_NAME : firstName,
                                                    PARAMS.LAST_NAME : lastName]
                
                do {
                    try await docReference.updateData(updatedData)
                    self.isAllowEdit.toggle()
                    AlertManager.shared.isShowGlobalLoading = false
                    AlertManager.shared.showAlert(title: String(localized: "SUCCESS"), message: String(localized: "PROFILE UPDATE SUCCESSFULLY"))
                    print("Document update successfully!")
                } catch {
                    print("ProfileViewModel : Error updating document: \(error.localizedDescription)")
                }
            }
        } else {
            isAllowEdit.toggle()
        }
    }
}
