//
//  FirebaseSync.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/24/26.
//

import Foundation
import SwiftData
import FirebaseFirestore

// Here we upload task to firebase using actor.
// actor - In Swift, an actor is a special type that protects its internal state from "data races."
// uploading happen in the background, using an actor ensures that multiple parts of app don't try to modify the database connection at the exact same millisecond.
// It handles synchronization.
final actor firebaseServices : Sendable {
    
    let db = Firestore.firestore()
    
    enum firebaseKeys : String {
        case id = "id"
        case title = "title"
        case notes = "notes"
        case dueDate = "dueDate"
        case priorityLevel = "priorityLevel" // 0 - Low, 1 - Medium, 2 - High
        case isCompleted = "isCompleted"
        case ownerId = "ownerId"
        case projectId = "projectID"
        case projectName = "projectName"
        case projectColor = "projectColor"
    }
    let collectionTask: String = "tasks"
    let userTasks: String = "userTasks"
    let collectionProject: String = "projects"
    let userProjects: String = "userProjects"
    
    //MARK: -
    //MARK: - For Tasks
    func uploadTask(taskModel: TaskTansferModel) async throws {
        
        let dictTask : [String : Any] = [firebaseKeys.id.rawValue : taskModel.id,
                                         firebaseKeys.title.rawValue : taskModel.title,
                                         firebaseKeys.notes.rawValue : taskModel.notes,
                                         firebaseKeys.dueDate.rawValue : taskModel.dueDate,
                                         firebaseKeys.priorityLevel.rawValue : taskModel.priorityLevel,
                                         firebaseKeys.isCompleted.rawValue : taskModel.isCompleted,
                                         firebaseKeys.ownerId.rawValue : taskModel.ownerId]
        
        try await db.collection(collectionTask)
            .document(taskModel.ownerId)
            .collection(userTasks)
            .document(taskModel.id)
            .setData(dictTask, merge: true)
    }
    func deleteTask(ownerId : String, taskId: String) async throws {
        try await db.collection(collectionTask).document(ownerId).collection(userTasks).document(taskId).delete()
    }
    func startTaskListner(ownerID: String) -> AsyncStream<[TaskTansferModel]> {
        AsyncStream { continuation in
            let listener = db.collection(collectionTask)
                .document(ownerID)
                .collection(userTasks)
                .addSnapshotListener { snapshot, error in
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    let taskItems = documents.compactMap({ doc -> TaskTansferModel? in
                        let data = doc.data()
                        
                        var dueDate : Date = .now
                        if let timestamp = data[firebaseKeys.dueDate.rawValue] as? Timestamp {
                            dueDate = timestamp.dateValue()
                        }
                        
                        return TaskTansferModel(id: data[firebaseKeys.id.rawValue] as? String ?? "",
                                                title: data[firebaseKeys.title.rawValue] as? String ?? "",
                                                notes: data[firebaseKeys.notes.rawValue] as? String ?? "",
                                                dueDate: dueDate,
                                                priorityLevel: data[firebaseKeys.priorityLevel.rawValue] as? Int ?? 1,
                                                isCompleted: data[firebaseKeys.isCompleted.rawValue] as? Bool ?? false,
                                                ownerId: data[firebaseKeys.id.rawValue] as? String ?? "")
                    })
                    continuation.yield(taskItems)
                }
            
            // Here we create sendable type to firebase listener
            let box = ListenerBox(listener: listener)
            continuation.onTermination = {@Sendable _ in
                box.stop()
            }
        }
    }
    //MARK: -
    //MARK: - For Projects
    func uploadProject(projectModel: ProjectTrasferModel) async throws {
        
        let data : [String : Any] = [firebaseKeys.projectId.rawValue : projectModel.id,
                                     firebaseKeys.projectName.rawValue : projectModel.name,
                                     firebaseKeys.ownerId.rawValue : projectModel.ownerId,
                                     firebaseKeys.projectColor.rawValue : projectModel.color]
        try await db.collection(collectionProject)
            .document(projectModel.ownerId)
            .collection(userProjects)
            .document(projectModel.id)
            .setData(data, merge: true)
    }
}

@Observable
@MainActor
class syncUnsyncFirebase {
    private var modelContext : ModelContext
    private let firebaseService : firebaseServices  = firebaseServices()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    //MARK:-
    //MARK: - Uploading all async task to firebase and updating flag into SWiftData
    
    func uploadAllTasks() async {
        
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate<TaskItem> { taskItem in
            !taskItem.isSynced && !taskItem.isDeleted
        })
        
        guard let allUnsyncedTasks = try? modelContext.fetch(descriptor) else { return }
        
        try? await withThrowingTaskGroup(of: String.self) { group in
            
            for taskItem in allUnsyncedTasks {
                
                let taskModel = TaskTansferModel(id: taskItem.id.uuidString,
                                                 title: taskItem.title,
                                                 notes: taskItem.notes,
                                                 dueDate: taskItem.dueDate,
                                                 priorityLevel: taskItem.priorityLevel,
                                                 isCompleted: taskItem.isCompleted,
                                                 ownerId: taskItem.ownerId)
                
                group.addTask {
                    try await self.firebaseService.uploadTask(taskModel: taskModel)
                    return taskModel.id
                }
            }
            
            for try await taskID in group {
                self.markAsSync(taskId: taskID)
            }
        }
    }
    
    private func markAsSync(taskId:String) {
        
        guard let uuid = UUID(uuidString: taskId) else { return }
        
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate<TaskItem> { $0.id == uuid })
        do {
            if let item = try modelContext.fetch(descriptor).first {
                item.isSynced = true
            }
        } catch {
            let error = error as Error
            print("FirebaseSync: error \(error.localizedDescription)")
        }
    }
    
    //MARK: -
    //MARK: - Deleting task from firebase
    // which is soft deleted from SwiftData. After firebase deletion will permenent delete from firebase
    func deleteTasks() async {
        
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate<TaskItem> { $0.isDeleted && !$0.isSynced })
        
        guard let deletedTasks = try? modelContext.fetch(descriptor) else { return }
        
        try? await withThrowingTaskGroup(of:String.self) { group in
            for task in deletedTasks {
                let taskId = task.id.uuidString
                let ownerId = task.ownerId
                group.addTask {
                    try await self.firebaseService.deleteTask(ownerId: ownerId, taskId: taskId)
                    return taskId
                }
            }
            
            for try await resultTaskID in group {
                self.deleteTaskFromSwiftData(taskId: resultTaskID)
            }
        }
    }
    func deleteTaskFromSwiftData(taskId : String) {
        
        guard let uuid = UUID(uuidString: taskId) else { return }
        
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate<TaskItem> { $0.id == uuid })
        
        do {
            if let item = try modelContext.fetch(descriptor).first
            {
                modelContext.delete(item)
                try? modelContext.save()
            }
        } catch {
            let error = error as Error
            print("FirebaseSync: error \(error.localizedDescription)")
        }
    }
    
    //MARK: -
    //MARK: - Task Listener
    func listenerForTaskChanges(userId:String?) async {
        guard let userId = userId else { return }
        
        let stream = await firebaseService.startTaskListner(ownerID: userId)
        
        for await remoteTasks in stream {
            for remoteTask in remoteTasks {
                guard let uuid = UUID(uuidString: remoteTask.id) else { continue }
                
                let descriptor = FetchDescriptor(predicate: #Predicate<TaskItem> { $0.id == uuid })
                let localTask = try? modelContext.fetch(descriptor).first
                
                if let task = localTask {
                    // Update task - only it is already sync. didn't update unsynced changes
                    if task.isSynced {
                        task.title = remoteTask.title
                        task.notes = remoteTask.notes
                        task.dueDate = remoteTask.dueDate
                        task.priorityLevel = remoteTask.priorityLevel
                        task.isCompleted = remoteTask.isCompleted
                    }
                } else {
                    // Add New task
                    let newTask = TaskItem(title: remoteTask.title,
                                           notes: remoteTask.notes,
                                           dueDate: remoteTask.dueDate,
                                           priorityLevel: remoteTask.priorityLevel,
                                           ownerId: userId)
                    newTask.isSynced = true
                    newTask.isCompleted = remoteTask.isCompleted
                    
                    modelContext.insert(newTask)
                }
                
                try? modelContext.save()
            }
            
            // Here handle delete task from other device or from firebase
            reconsile(remoteTasks: remoteTasks, userId: userId)
        }
    }
    
    func reconsile(remoteTasks:[TaskTansferModel], userId: String) {
        
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate<TaskItem>{ $0.isSynced == true && $0.ownerId == userId })
        
        let localTasks = (try? modelContext.fetch(descriptor)) ?? []
        
        let remoteIds = Set(remoteTasks.map { $0.id })
        
        for task in localTasks {
            if !remoteIds.contains(task.id.uuidString) {
                modelContext.delete(task)
            }
        }
        
        try? modelContext.save()
    }
    
    //MARK: -
    //MARK: - uploading all projects to firebase and updating isSynced flag
    func uploadAllProjects() async {
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate<Project>{
            !$0.isSynced
        })
        
        guard let allUnsyncedProjects = try? modelContext.fetch(descriptor) else { return }
        
        try? await withThrowingTaskGroup(of:String.self) { group in
            
            for project in allUnsyncedProjects {
                let projectModel = ProjectTrasferModel(id: project.id.uuidString,
                                                       name: project.name,
                                                       ownerId: project.ownerId,
                                                       color: project.color)
                group.addTask {
                    try await self.firebaseService.uploadProject(projectModel: projectModel)
                    return projectModel.id
                }
            }
            
            for try await projectId in group {
                self.syncProject(projectId: projectId)
            }
        }
    }
    func syncProject(projectId: String) {
        guard let id = UUID(uuidString: projectId) else { return }
        let descriptor = FetchDescriptor<Project>(predicate:#Predicate<Project>{ $0.id == id })
        
        let project = try? modelContext.fetch(descriptor).first
        
        if let project = project {
            project.isSynced = true
            try? modelContext.save()
        }
    }
}
