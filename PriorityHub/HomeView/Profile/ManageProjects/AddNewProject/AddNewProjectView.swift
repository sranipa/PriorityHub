//
//  AddNewProjectView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 4/10/26.
//

import SwiftUI

struct AddNewProjectView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var viewModel : AddNewProjectViewModel
    
    var body: some View {
        Form {
            Text("ADD_NEW_PROJECT")
                .font(.title)
                .padding(.top)
                .bold()
            
            TextField("NAME", text: $viewModel.projectName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
            
            Button {
                viewModel.addNewProject(completion: {
                    dismiss()
                })
            } label: {
                Text("SUBMIT")
                    .frame(maxWidth:.infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isAddProjectSubmitDisable)
        }
    }
}

//#Preview {
//    AddNewProjectView()
//}
