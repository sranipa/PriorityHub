//
//  ProfileModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/12/26.
//

import Foundation
class ProfileModel : Codable {
    var uid : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    
    /* - Kept this for reference.
    // If your Firestore field names are different (e.g., "first_name"),
    // you can map them using CodingKeys:
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
    */
}
