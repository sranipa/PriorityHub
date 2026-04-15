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
}
