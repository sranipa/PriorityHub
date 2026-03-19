//
//  Helper.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/10/26.
//

import Foundation

//MARK: - Firestore collection name
struct COLLECTION {
    static let USERS : String = "users"
}

//MARK: - Firestore API Param name
struct PARAMS {
    static let FIRST_NAME : String = "firstName"
    static let LAST_NAME : String = "lastName"
    static let EMAIL : String = "email"
    static let CREATED_AT : String = "createdAt"
}

//MARK: - Cosntant
struct CONSTANT {
    static let IS_DARK_MODE : String = "isDarkMode"
}


//MARK: -
//MARK: - Get Date fromatted
func getDate(date:Date) -> String {
    if Calendar.current.isDateInToday(date) {
        return String(localized: "TODAY")
    } else if Calendar.current.isDateInTomorrow(date) {
        return String(localized: "TOMORROW")
    } else if Calendar.current.isDateInYesterday(date) {
        return String(localized: "YESTERDAY")
    } else {
        return date.formatted(date:.abbreviated, time: .omitted)
    }
}
