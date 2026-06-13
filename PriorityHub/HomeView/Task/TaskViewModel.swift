//
//  TaskViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/22/26.
//

import Foundation
import SwiftData

@Observable
@MainActor
class TaskViewModel {
    
    enum sortOptions : String, CaseIterable {
        case dueDate = "Date"
        case priority = "Priority"
        case project = "Project"
    }
    var sortOption : sortOptions = .dueDate
    var searchText : String = ""
    
    //MARK: -
    //MARK: - Grouping the all task
    func getGroupedTask(tasks:[TaskItem]) -> [(header:String, tasks:[TaskItem])] {
        
        let filteredTasks = tasks.filter { task in
            searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .dueDate:
            // Get all over due tasks
            let overDueTasks = filteredTasks.filter { task in
                task.dueDate < Calendar.current.startOfDay(for: .now)
            }
            
            // get all task which in not overdue
            let AllOtherTasks = filteredTasks.filter { task in
                task.dueDate >= Calendar.current.startOfDay(for: .now)
            }
            
            // Grouping & Sorting of all not overdue tasks
            let dict = Dictionary(grouping: AllOtherTasks) { item in
                Calendar.current.startOfDay(for: item.dueDate)
            }
            var groupedSection = dict.sorted { item1, item2 in
                item1.key < item2.key
            }.map { (header: getDate(date: $0.key), tasks: $0.value) }
            
            // Adding overdue task at first
            if !overDueTasks.isEmpty {
                groupedSection.insert((header:CONSTANT.OVERDUE, tasks:overDueTasks), at: 0)
            }
            
            return groupedSection
            
            
        case .priority:
            let dict = Dictionary(grouping: filteredTasks, by: {$0.priorityLevel})

            return dict.sorted { $0.key > $1.key }
                .map{ (header:PriorityLevel(rawValue: $0.key)?.label ?? $0.key.description, tasks: $0.value ) }
             
        case .project:
            let dict = Dictionary(grouping: filteredTasks) { item in
                item.project?.name ?? "No Project"
            }
            
            return dict.sorted { $0.key < $1.key }
                .map{ (header: $0.key, tasks: $0.value) }
        }
    }
    
    //MARK: -
    //MARK: - Complete Task 
    func onComplete(modelContext: ModelContext, taskItem: TaskItem){
        taskItem.isCompleted = true
        taskItem.completedAt = .now
        taskItem.isSynced = false
        try? modelContext.save()
        Task {
            await syncUnsyncFirebase(modelContext: modelContext).uploadAllTasks()
        }
    }
    //MARK: -
    //MARK: - Perform delete operation for TaskItem
    func onDelete(modelContext: ModelContext, taskItem: TaskItem) {
        let strMsg : String = String(localized: "ARE_YOU_SURE_YOU_WANT_TO_DELETE") + " \(taskItem.title)?"
        AlertManager.shared.showAlert(title: String(localized: "ALERT!"), message: strMsg, okTitle: String(localized: "DELETE"),isDestructive: true, okAction: {
            taskItem.isTaskDelete = true
            taskItem.isSynced = false
//            modelContext.delete(taskItem)
            try? modelContext.save()
            Task {
                await syncUnsyncFirebase.init(modelContext: modelContext).deleteTasks()
            }
        }, cancelTitle: String(localized: "CANCEL"),cancelAction: {
            
        })
    }
    
}
