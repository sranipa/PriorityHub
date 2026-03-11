//
//  AlertManager.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/9/26.
//

import Foundation
import SwiftUI

@Observable
class AlertManager {
    static let shared = AlertManager()
    
    // Global Loading state
    var isShowGlobalLoading: Bool = false
    
    // Gloabal Alert
    var isShowing : Bool = false
    var title : String = ""
    var message : String = ""
    
    var okTitle : String = ""
    var isDestructive: Bool = false
    var okAction : (() -> Void)?
    
    var cancelTitle : String?
    var cancelAction : (() -> Void)?
    
    func showAlert(title: String,
                   message: String,
                   okTitle: String = String(localized: "OK"),
                   isDestructive: Bool = false,
                   okAction: (() -> Void)? = nil,
                   cancelTitle: String? = nil,
                   cancelAction: (() -> Void)? = nil)
    {
        self.title = title
        self.message = message
        self.okTitle = okTitle
        self.isDestructive = isDestructive
        self.okAction = okAction
        self.cancelTitle = cancelTitle
        self.cancelAction = cancelAction
        self.isShowing = true
    }
    
}
