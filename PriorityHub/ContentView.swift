//
//  ContentView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(GlobalObject.self) private var globalObject
    var body: some View {
        if globalObject.isUserLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
