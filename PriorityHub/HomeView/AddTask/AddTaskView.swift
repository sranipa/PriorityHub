//
//  AddTaskView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/11/26.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var viewModel : AddTaskViewModel
    @FocusState private var focusField : AddTaskField?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ADD_TASK")
                .font(.title)
                .padding(.top)
                .bold()
            
            TextField("TITLE", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .focused($focusField, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    focusField = .note
                }
            
            TextField("NOTE", text: $viewModel.note)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .focused($focusField, equals: .note)
                .submitLabel(.next)
                .onSubmit {
                    focusField = .date
                }
            
            Spacer()
            
            Button(action: {
                viewModel.addTask(completion: {
                    dismiss()
                })
            }, label: {
                Text("ADD_TASK")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSubmitDisable)
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            focusField = .none
        }
    }
}

//#Preview {
//    AddTaskView()
//}
//MARK: -
//MARK: - Only for View
private enum AddTaskField : Hashable {
    case title
    case note
    case date
    case priority
    case project
}
