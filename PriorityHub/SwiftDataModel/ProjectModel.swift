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
    var color : String
    
    // Relationship: One project can have many tasks
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks : [TaskItem] = []
    
    init(id: UUID = UUID(), name: String, color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.color = color
        self.tasks = tasks
    }
}
