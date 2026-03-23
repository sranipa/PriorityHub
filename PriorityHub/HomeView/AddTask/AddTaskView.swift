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
    
    @State var isShowAddProject : Bool = false
    
    var body: some View {
        Form {
            Text("ADD_TASK")
                .font(.title)
                .padding(.top)
                .bold()
            
            TextField("TITLE", text: $viewModel.title)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .focused($focusField, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    focusField = .note
                }
            
            TextField("NOTE", text: $viewModel.note)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .focused($focusField, equals: .note)
                .submitLabel(.next)
                .onSubmit {
                    focusField = .none
                }
            
            viewForSelectProject
            
            viewForDatePicker
            
            viewForPriorityLevel
            
            viewForSubmitButton
        }
        .sheet(isPresented: $isShowAddProject, content: {
            viewForAddNewProject
        })
    }
    //MARK: -
    //MARK: - ViewForSubmit Button
    var viewForSubmitButton : some View {
        if viewModel.isFromEdit {
            Button(action: {
                viewModel.updateTask(completion: {
                    dismiss()
                })
            }, label: {
                Text("UPDATE_TASK")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSubmitDisable)
        } else {
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
    }
    
    //MARK: -
    //MARK: - View For Priority
    var viewForPriorityLevel : some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PRIORITY")
                .foregroundColor(.primary)
            
            Picker("SELECT_PRIORITY", selection: $viewModel.priorityLevel) {
                ForEach(PriorityLevel.allCases) { level in
                    Text(level.label).tag(level)
                }
            }.pickerStyle(.segmented)
        }
    }
    //MARK: -
    //MARK: - Due Date -Date Picker View
    var viewForDatePicker : some View {
        DatePicker("DUE_DATE",
                   selection: $viewModel.dueDate,
                   in: Date()...,
                   displayedComponents: .date)
            .datePickerStyle(.compact)
            .background(Color.clear)
    }
    
    //MARK: -
    //MARK: - Project Selection Picker & Add New Project View
    var viewForSelectProject : some View {
        HStack(spacing:5) {
            Text(String(localized: "SELECT_PROJECT"))
                .foregroundStyle(Color.primary)
            
            Spacer()
            
            Menu {
                // 1. The Selectable Projects
                ForEach(viewModel.projects) { project in
                    Button {
                        withAnimation(.snappy) {
                            viewModel.selectedProject = project
                        }
                    } label: {
                        HStack {
                            Text(project.name)
                            if viewModel.selectedProject?.id == project.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                // 2. The Action Button For Add New Project
                Button(action: {
                    isShowAddProject.toggle()
                }, label: {
                    Label(String(localized: "ADD_NEW_PROJECT"), systemImage: "plus")
                })
                
            } label: {
                // 3. The Custom "Picker" Label
                    HStack(spacing:5) {
                    Text(viewModel.selectedProject?.name ?? String(localized: "SELECT_PROJECT"))
                        .foregroundStyle(viewModel.selectedProject == nil ? Color.gray : Color.primary)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                }
                
            }
            .animation(.spring(duration: 0.3), value: viewModel.selectedProject?.id)
        }
    }
    var viewForAddNewProject : some View {
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
                    isShowAddProject.toggle()
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
enum PriorityLevel : Int, Identifiable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var id : Int { self.rawValue }
    
    var label : String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
    var color : Color {
        switch self {
        case .low:
            return .blue
        case .medium:
            return .gray
        case .high:
            return .red
        }
    }
}
