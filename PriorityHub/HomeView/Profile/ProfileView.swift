//
//  ProfileView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/11/26.
//

import SwiftUI

struct ProfileView: View {
    // The key that persists the setting
    @AppStorage(CONSTANT.IS_DARK_MODE) private var isDarkMode: Bool = false
    @State private var viewModel : ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    NavigationLink {
                        UserProfileView()
                    } label: {
                        Label("ACCOUNT", systemImage: "key")
                            .foregroundStyle(Color.primary)
                    }
                    
                    Toggle(isOn: $isDarkMode) {
                        Label("DARK_MODE", systemImage:"moon")
                            .foregroundStyle(Color.primary)
                    }
                }
                
                Section {
                    profileRow(icon: "power", name:String(localized:"LOGOUT"))
                        .onTapGesture {
                            viewModel.showAlertForLogout()
                        }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}
struct profileRow : View {
    
    var icon: String
    var name: String
    
    var body: some View {
        HStack(spacing:15) {
            Image(systemName: icon)
            
            Text(name)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProfileView()
}
