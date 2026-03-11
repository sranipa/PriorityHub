//
//  GlobalAlertModifier.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/9/26.
//

import Foundation
import SwiftUI

struct GlobalAlertModifier : ViewModifier {
    
    @Bindable var manager = AlertManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if manager.isShowing {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                
                CustomAlertView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
extension View {
    func globalAlertView() -> some View {
        self.modifier(GlobalAlertModifier())
    }
}
