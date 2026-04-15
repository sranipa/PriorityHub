//
//  AddNewProjectViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 4/10/26.
//

import Foundation
import SwiftData

@Observable
class AddNewProjectViewModel {

    init(isForEdit: Bool, modelContext: ModelContext, editProjectItem: Project? = nil) {
        self.isForEdit = isForEdit
        self.modelContext = modelContext
        if isForEdit {
            self.editProjectItem = editProjectItem
            self.projectName = editProjectItem?.name ?? ""
        }
    }
    
    var modelContext : ModelContext
    
    var isForEdit: Bool
    var editProjectItem : Project? = nil
    
    var projectName : String = ""
    var isAddProjectSubmitDisable : Bool {
        return projectName.trimmingCharacters(in: .whitespaces).isEmpty || (isForEdit && projectName == editProjectItem?.name)
    }
    //MARK: -
    //MARK: - Add New Project
    func addNewProject(completion: @escaping() -> Void) {
        if isForEdit {
            editProjectItem?.name = self.projectName
            editProjectItem?.isSynced = false
            try? modelContext.save()
            syncProjects()
            completion()
        } else {
            if let uid = getFirebaseUserID() {
                let newProject : Project = Project(name: projectName, ownerId: uid)
                modelContext.insert(newProject)
                do {
                    try  modelContext.save()
    //                selectedProject = newProject
    //                projects.append(newProject)
    //                firebaseSync(isForProject: true)
                    syncProjects()
                    completion()
                } catch {
                    print("AddTaskViewModel - Failed To Save Task: \(error.localizedDescription)")
                }
            }
        }
    }
    func syncProjects(){
        let objSyncAsync = syncUnsyncFirebase(modelContext: modelContext)
        Task {
            await objSyncAsync.uploadAllProjects()
        }
    }
}
