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
    
    func uploadTask(taskModel : TaskTansferModel) async throws {
        
        let dictTask : [String : Any] = [firebaseKeys.id.rawValue : taskModel.id,
                                         firebaseKeys.title.rawValue : taskModel.title,
                                         firebaseKeys.notes.rawValue : taskModel.notes,
                                         firebaseKeys.dueDate.rawValue : taskModel.dueDate,
                                         firebaseKeys.priorityLevel.rawValue : taskModel.priorityLevel,
                                         firebaseKeys.isCompleted.rawValue : taskModel.isCompleted,
                                         firebaseKeys.ownerId.rawValue : taskModel.ownerId]
        
        try await db.collection("tasks").document(taskModel.ownerId).collection("userTasks").document(taskModel.id).setData(dictTask, merge: true)
    }
    
    enum firebaseKeys : String {
        case id = "id"
        case title = "title"
        case notes = "notes"
        case dueDate = "dueDate"
        case priorityLevel = "priorityLevel" // 0 - Low, 1 - Medium, 2 - High
        case isCompleted = "isCompleted"
        case ownerId = "ownerId"
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
    
    func uploadAllTasks() async {
        
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate<TaskItem> { taskItem in
            !taskItem.isSynced
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
}
