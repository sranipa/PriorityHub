//
//  ManageProjectsViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 4/3/26.
//

import Foundation
import SwiftData

@Observable
class ManageProjectsViewModel {
    
    var isShowAddProject : Bool = false
    var searchText : String = ""
    
    func getFilteredList(allProjects : [Project]) -> [Project] {
        return allProjects.filter { project in
            searchText.isEmpty || project.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    
    func deleteProject(modelContext: ModelContext, projectItem: Project) {
        projectItem.isProjectDelete = true
        projectItem.isSynced = false
        try? modelContext.save()
        Task {
            await syncUnsyncFirebase(modelContext: modelContext).uploadAllProjects()
        }
    }
    func selectedProject(modelContext: ModelContext, project: Project) {
        
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate<Project>{ $0.isProjectSelected })
        guard let selectedProject = try? modelContext.fetch(descriptor).first else { return }
        
        selectedProject.isProjectSelected = false // disable old selection
        selectedProject.isSynced = false
        
        project.isProjectSelected = true // enable new selection
        project.isSynced = false
        
        try? modelContext.save()
        
        Task {
            await syncUnsyncFirebase(modelContext: modelContext).uploadAllProjects()
        }
    }
    //MARK: -
    //MARK: - Adding Default Project
    func addDefaultProject(modelContext: ModelContext,) {
        let descriptor = FetchDescriptor<Project>(predicate:#Predicate{$0.isDefaultProject})
        do {
            let project = try modelContext.fetch(descriptor)
            
            //If not found then we will add one
            if project.isEmpty, let uid = getFirebaseUserID() {
                let defaultProject = Project.init(name: "Inbox", ownerId: uid)
                defaultProject.isDefaultProject = true
                defaultProject.isProjectSelected = true
                modelContext.insert(defaultProject)
                try modelContext.save()
                Task {
                    await syncUnsyncFirebase(modelContext: modelContext).uploadAllProjects()
                }
            }
        } catch {
            print("AddTaskViewModel: \(error.localizedDescription)")
        }
    }
}
