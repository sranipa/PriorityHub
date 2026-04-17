//
//  TaskModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/17/26.
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title : String
    var notes : String
    var dueDate : Date
    var priorityLevel : Int // 0 - Low, 1 - Medium, 2 - High
    var isCompleted : Bool
    var isSynced : Bool
    var ownerId : String
    var isTaskDelete : Bool
    
    // The relationship back to the Project
    var project : Project?
    
    init(id: UUID = UUID(),
         title: String,
         notes: String = "",
         dueDate: Date = .now,
         priorityLevel: Int = 1,
         ownerId: String)
    {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priorityLevel = priorityLevel
        self.isCompleted = false
        self.isSynced = false
        self.ownerId = ownerId
        self.isTaskDelete = false
    }
}
// Here we create TaskTansferModel for transfer SwiftData model to Firebase.
// SwiftData model is Class- so it's reference type.
// For structure concurrency we can't play with reference object inbetween MainActor & background thread.
// We create uploadTask function into actor and also we create uploadAllTasks() async function.
// So it will run on background thread.
// Swift6 is strict about concurrency while working with MainActor & Background thread.
// Also we kept Sendable.
// So we info to Swift - Here we sure that all data is value type and safe to access in background.
struct TaskTansferModel : Sendable {
    var id: String
    var title : String
    var notes : String
    var dueDate : Date
    var priorityLevel : Int // 0 - Low, 1 - Medium, 2 - High
    var isCompleted : Bool
    var ownerId : String
    var projectId : String
}
