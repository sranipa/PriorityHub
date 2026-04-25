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
    
    @Query(FetchDescriptor<Project>(predicate: #Predicate<Project>{$0.isProjectSelected})) var selectedProjects : [Project]
    
    var body: some View {
        NavigationStack {
            Form {
//                Text(viewModel.HeaderTitle)
//                    .font(.title)
//                    .padding(.top)
//                    .bold()
                
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
                    .onAppear {
                        // Here we first time display edit item's default project.
                        // Then it will display default selected project
                        // For Add Item it should be display default project
                        if viewModel.isFromEdit && viewModel.isEditFirstTime {
                            viewModel.isEditFirstTime = false
                        } else {
                            viewModel.selectedProject = selectedProjects.first
                        }
                    }
                
                viewForDatePicker
                
                viewForPriorityLevel
                
                viewForSubmitButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.HeaderTitle)
            .onAppear {
                viewModel.addDefaultProject()
            }
        }
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
    
    var viewForSelectProject : some View {
        NavigationLink {
            ManageProjectsView()
        } label: {
            HStack {
                Text("SELECT_PROJECT")
                
                Spacer()
                
                Text(viewModel.selectedProject?.name ?? String(localized: "SELECT_PROJECT"))
                    .foregroundStyle(viewModel.selectedProject == nil ? Color.gray : Color.primary)
            }
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
            return .yellow
        case .high:
            return .red
        }
    }
}
