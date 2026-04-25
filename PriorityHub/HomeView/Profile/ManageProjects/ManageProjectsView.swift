//
//  ManageProjectsView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 4/3/26.
//

import SwiftUI
import SwiftData

struct ManageProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Project>{ project in
        !project.isProjectDelete }, sort: [SortDescriptor(\Project.name)]) private var allProjects : [Project]
    
    @State private var viewModel = ManageProjectsViewModel()
    @State private var editProjectItem : Project? = nil
    
    var body: some View {
            viewForProjectList
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search")
            .toolbar {
                Button {
                    viewModel.isShowAddProject.toggle()
                } label: {
                    Label("ADD", systemImage: "plus")
                }
            }
            .sheet(isPresented: $viewModel.isShowAddProject) {
               AddNewProjectView(viewModel: AddNewProjectViewModel(isForEdit: false, modelContext: modelContext))
            }
            .sheet(item: $editProjectItem, content: { projectItem in
                AddNewProjectView(viewModel: AddNewProjectViewModel(isForEdit: true, modelContext: modelContext, editProjectItem: projectItem))
            })
            .onAppear {
                viewModel.addDefaultProject(modelContext: modelContext)
            }
    }
    var viewForProjectList : some View {
        List {
            ForEach(viewModel.getFilteredList(allProjects: allProjects), id: \.self) { projectItem in
                viewForRow(projectItem: projectItem)
            }
        }.listStyle(.insetGrouped)
    }
    //MARK: - Design Row Here
    @ViewBuilder
    func viewForRow(projectItem: Project) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(projectItem.name)
                
                if projectItem.isDefaultProject {
                    Text("DEFAULT_PROJECT_MESSAGE")
                        .font(.caption2)
                        .foregroundStyle(Color.red)
                }
            }
            
            Spacer()
            
            if projectItem.isProjectSelected {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectedProject(modelContext: modelContext, project: projectItem)
        }
        .id(projectItem.id)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !projectItem.isDefaultProject {
                Button {
                    viewModel.deleteProject(modelContext: modelContext, projectItem: projectItem)
                } label: {
                    Label("DELETE", systemImage: "trash")
                }.tint(.red)
                
                Button {
                    editProjectItem = projectItem
                } label: {
                    Label("EDIT", systemImage: "square.and.pencil")
                }.tint(.blue)
            }
        }
    }
}

#Preview {
    ManageProjectsView()
}
