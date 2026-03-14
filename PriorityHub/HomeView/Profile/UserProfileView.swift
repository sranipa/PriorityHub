//
//  UserProfileView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/12/26.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(GlobalObject.self) var globalObject
    @FocusState private var focusedField: UserProfileField?
    @State private var viewModel : UserProfileViewModel = UserProfileViewModel()
    
    var body: some View {
        VStack(spacing:20) {
            firstNameView
            
            lastNameView
            
            emailView
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = .none
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    Task {
                        await viewModel.updateUserDetails()
                    }
                }, label: {
                    Image(systemName: viewModel.isAllowEdit ? "checkmark" : "square.and.pencil")
                })
            }
        }
        .onAppear {
            if let user = globalObject.currentUser {
                viewModel.firstName = user.firstName
                viewModel.lastName = user.lastName
                viewModel.userEmail = user.email
                viewModel.uid = user.uid
                globalObject.addListnerForUserProfileData()
            }
        }
    }
    private var firstNameView : some View {
        TextField("FIRST_NAME", text: $viewModel.firstName)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .focused($focusedField, equals: .firstName)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .lastName
            }
            .disabled(!viewModel.isAllowEdit)
    }
    private var lastNameView : some View {
        TextField("LAST_NAME", text: $viewModel.lastName)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .focused($focusedField, equals: .lastName)
            .submitLabel(.next)
            .onSubmit { focusedField  = nil }
            .disabled(!viewModel.isAllowEdit)
    }
    private var emailView : some View {
        ZStack {
            TextField("EMAIL", text: $viewModel.userEmail)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .disabled(true)
            
            HStack() {
                Spacer()
                
                Button {
                    viewModel.showPopup = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.primary)
                }
                .padding(.trailing,5)
                .popover(isPresented: $viewModel.showPopup, content: {
                    Text(String(localized: "YOU_CANT_CHANGE_ADDRESS"))
                        .font(.body)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                })
            }
        }
    }
}

#Preview {
    UserProfileView()
}
enum UserProfileField : Hashable {
    case firstName
    case lastName
    case email
}
