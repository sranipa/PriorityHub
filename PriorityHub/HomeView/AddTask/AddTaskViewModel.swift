//
//  AddTaskViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/17/26.
//

import Foundation
@Observable
class AddTaskViewModel {
    
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
    func addTask() {
        if isValidForm {
            print("Added new task")
        } else {
            AlertManager.shared.showAlert(title: "ALERT!", message: "PLEASE_ENTER_TASK_TITLE")
        }
    }
}
