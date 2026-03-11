//
//  LoadingViewModifier.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/9/26.
//

import SwiftUI

struct LoadingViewModifier : ViewModifier {
    var isLoading : Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
               .disabled(isLoading) // Prevent user input while loading
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView("PLEASE_WAIT...")
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThickMaterial))
                    }
            }
        }
    }
}
extension View {
    func loadingOverlay(isLoading:Bool) -> some View {
        self.modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
