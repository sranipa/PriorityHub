//
//  AddTaskViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/17/26.
//

import Foundation
import SwiftData

@Observable
@MainActor
class AddTaskViewModel {
    
    private var modelContext : ModelContext
    init(modelContext: ModelContext, isFromEdit: Bool = false, editTaskItem : TaskItem? = nil) {
        self.modelContext = modelContext
        self.isFromEdit = isFromEdit
        self.editTaskItem = editTaskItem
        self.addDefaultProject() // There is no any project we will add default "Inbox" project
        self.getAllProjects() // Fetch all saved projects
        if self.isFromEdit {
            self.title = editTaskItem?.title ?? ""
            self.note = editTaskItem?.notes ?? ""
            self.dueDate = editTaskItem?.dueDate ?? .now
            self.priorityLevel = PriorityLevel(rawValue: editTaskItem?.priorityLevel ?? 1) ?? .medium
            self.selectedProject = editTaskItem?.project
        }
    }
    var HeaderTitle : String {
        if isFromEdit {
            String(localized: "EDIT_TASK")
        } else {
            String(localized: "ADD_TASK")
        }
    }
    // For Edit Task
    var isFromEdit : Bool = false
    var editTaskItem : TaskItem? = nil
    
    // All Saved projects
    var projects : [Project] = []
    
    // This is for Add New Project
    var projectName : String = ""
    var isAddProjectSubmitDisable : Bool {
        projectName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    let DefaultProjectName: String = "Inbox"
    
    // Selected Project -
    // By default we will save first project from Projects Array
    var selectedProject : Project? = nil
    
    private var model = AddTaskModel()
    var title : String {
        get { model.title }
        set { model.title = newValue }
    }
    var note : String {
        get { model.note }
        set { model.note = newValue }
    }
    var dueDate : Date {
        get { model.dueDate }
        set { model.dueDate = newValue }
    }
    var priorityLevel : PriorityLevel {
        get { model.priorityLevel }
        set { model.priorityLevel = newValue }
    }
    var project : Project? {
        get { model.project }
        set { model.project = newValue }
    }
    var isSubmitDisable : Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    var isValidForm : Bool {
        return !title.isEmpty
    }
    
    //MARK: -
    //MARK: - Add New Project
    func addNewProject(completion: @escaping() -> Void) {
        if let uid = getFirebaseUserID() {
            let newProject : Project = Project(name: projectName, ownerId: uid)
            modelContext.insert(newProject)
            do {
                try  modelContext.save()
                selectedProject = newProject
                projects.append(newProject)
                firebaseSync(isForProject: true)
                completion()
            } catch {
                print("AddTaskViewModel - Failed To Save Task: \(error.localizedDescription)")
            }
        }
    }
    //MARK: -
    //MARK: - Update taskItem
    func updateTask(completion: @escaping() -> Void) {
        if let task = editTaskItem {
            task.title = title
            task.notes = note
            task.project = selectedProject
            task.dueDate = dueDate
            task.priorityLevel = priorityLevel.rawValue
            task.isSynced = false
            
            do {
                try modelContext.save()
                firebaseSync(isForProject: false)
                completion() // Here we will return completion so In View we can dismiss sheet
            } catch {
                print("AddTaskViewModel - Failed To Save Task: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: -
    //MARK: - ADDTask to SwiftData - Local Storage
    func addTask(completion: @escaping() -> Void) {
        if isValidForm {
            if let uid = getFirebaseUserID() {
                let newTask = TaskItem(title: title,
                                       notes: note,
                                       dueDate: dueDate,
                                       priorityLevel: priorityLevel.rawValue,
                                       ownerId: uid)
                newTask.project = selectedProject
                modelContext.insert(newTask)
                do {
                    try modelContext.save()
                    firebaseSync(isForProject: false)
                    completion() // Here we will return completion so In View we can dismiss sheet
                } catch {
                    print("AddTaskViewModel - Failed To Save Task: \(error.localizedDescription)")
                }
            }
        } else {
            AlertManager.shared.showAlert(title: "ALERT!", message: "PLEASE_ENTER_TASK_TITLE")
        }
    }
    func firebaseSync(isForProject:Bool) {
        let objSyncAsync = syncUnsyncFirebase.init(modelContext: modelContext)
        if isForProject {
            Task {
                await objSyncAsync.uploadAllProjects()
            }
        } else {
            Task {
                await objSyncAsync.uploadAllTasks()
            }
        }
    }
    
    //MARK: -
    //MARK: - Fetch All Project
    @MainActor
    func getAllProjects() {
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate<Project>{!$0.isProjectDelete},sortBy: [SortDescriptor(\Project.name)])
        do {
            projects = try modelContext.fetch(descriptor)
            
            // Selected project is nil. then we will set INBOX to default one.
            if let firstProject = projects.first(where: {$0.name == DefaultProjectName}), selectedProject == nil
            {
                selectedProject = firstProject
            }
        } catch {
            print("AddTaskViewModel: \(error.localizedDescription)")
        }
    }
    //MARK: -
    //MARK: - We will add default project if any project is not available.
    func addDefaultProject() {
        let predicate = #Predicate<Project> { project in
            project.name == DefaultProjectName
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\Project.name)])
        do {
            // Fetch "Inbox" project from database
            let project = try modelContext.fetch(descriptor)
            
            //If not found then we will add one
            if project.isEmpty, let uid = getFirebaseUserID() {
                let defaultProject = Project.init(name: DefaultProjectName, ownerId: uid)
                defaultProject.isDefaultProject = true
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
