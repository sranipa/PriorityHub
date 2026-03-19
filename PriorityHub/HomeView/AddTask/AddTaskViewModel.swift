//
//  AddTaskViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/17/26.
//

import Foundation
import SwiftData

@Observable
class AddTaskViewModel {
    
    private var modelContext : ModelContext
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.addDefaultProject() // There is no any project we will add default "Inbox" project
        self.getAllProjects() // Fetch all saved projects
    }
    
    // All Saved projects
    var projects : [Project] = []
    
    // Selected Project -
    // By default we will save first project from Projects Array
    var selectedProject : Project?
    
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
    var priorityLevel : Int {
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
    //MARK: - ADDTask to SwiftData - Local Storage
    func addTask(completion: @escaping() -> Void) {
        if isValidForm {
            if let uid = getFirebaseUserID() {
                let newTask = TaskItem(title: title, ownerId: uid)
                newTask.project = selectedProject
                modelContext.insert(newTask)
                do {
                    try modelContext.save()
                    completion() // Here we will return completion so In View we can dismiss sheet
                } catch {
                    print("AddTaskViewModel - Failed To Save Task: \(error.localizedDescription)")
                }
            }
        } else {
            AlertManager.shared.showAlert(title: "ALERT!", message: "PLEASE_ENTER_TASK_TITLE")
        }
    }
    
    //MARK: -
    //MARK: - Fetch All Project
    @MainActor
    func getAllProjects() { 
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\Project.name)])
        do {
            projects = try modelContext.fetch(descriptor)
            
            if let firstProject = projects.first {
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
            project.name == "Inbox"
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\Project.name)])
        do {
            // Fetch "Inbox" project from database
            let project = try modelContext.fetch(descriptor)
            
            //If not found then we will add one
            if project.isEmpty {
                let defaultProject = Project.init(name: "Inbox")
                modelContext.insert(defaultProject)
                try modelContext.save()
            }
        } catch {
            print("AddTaskViewModel: \(error.localizedDescription)")
        }
    }
}
