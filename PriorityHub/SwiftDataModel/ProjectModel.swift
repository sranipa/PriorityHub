//
//  ProjectModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/17/26.
//

import Foundation
import SwiftData

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name : String
    var isSynced : Bool
    var ownerId : String
    var isProjectDelete : Bool
    var isDefaultProject : Bool
    var color : String
    
    // Relationship: One project can have many tasks
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks : [TaskItem] = []
    
    init(id: UUID = UUID(), name: String, ownerId: String, color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.isSynced = false
        self.isProjectDelete = false
        self.isDefaultProject = false
        self.ownerId = ownerId
        self.color = color
        self.tasks = tasks
    }
}

struct ProjectTrasferModel : Codable {
    var id: String
    var name : String
    var ownerId : String
    var isDefaultProject : Bool
    var color : String
}
