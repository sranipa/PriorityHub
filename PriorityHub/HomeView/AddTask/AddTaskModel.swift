//
//  AddTaskModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/17/26.
//

import Foundation

struct AddTaskModel {
    var title : String = ""
    var note : String = ""
    var dueDate : Date = .now
    var priorityLevel : Int = 1 // 0 - Low, 1 - Medium, 2 - High
    var project : Project? = nil
}
