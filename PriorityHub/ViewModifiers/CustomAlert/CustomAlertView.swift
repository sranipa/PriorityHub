//
//  CustomAlertView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/9/26.
//

import Foundation
import SwiftUI

struct CustomAlertView : View {
    
    @Bindable var manager = AlertManager.shared
    
    var body: some View {
        VStack(spacing:20) {
            
            Text(manager.title)
                .font(.headline)
            
            Text(manager.message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Divider()
            
            HStack(spacing: 15) {
                // Conditionally show cancel button
                if let cancelTitle = manager.cancelTitle {
                    Button {
                        manager.cancelAction?()
                        manager.isShowing = false
                    } label: {
                        Text(cancelTitle)
                            .frame(minWidth: 100)
                    }.buttonStyle(.borderedProminent)
                }
                
                // Ok Button
                Button {
                    manager.okAction?()
                    manager.isShowing = false
                } label: {
                    Text(manager.okTitle)
                        .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                .tint(manager.isDestructive ? .red : .blue)
            }
        }
        .padding(30)
        .frame(minWidth: 300)
        .background(.ultraThickMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(40)
    }
}
#Preview {
    CustomAlertView(manager: AlertManager.shared)
}
