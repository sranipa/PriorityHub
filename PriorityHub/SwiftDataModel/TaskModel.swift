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
    }
}
