//
//  TaskViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/22/26.
//

import Foundation
import SwiftData

@Observable
class TaskViewModel {
    
    //MARK: -
    //MARK: - Perform delete operation for TaskItem
    func onDelete(modelContext: ModelContext, taskItem: TaskItem) {
        let strMsg : String = String(localized: "ARE_YOU_SURE_YOU_WANT_TO_DELETE") + " \(taskItem.title)?"
        AlertManager.shared.showAlert(title: String(localized: "ALERT!"), message: strMsg, okTitle: String(localized: "DELETE"),isDestructive: true, okAction: {
            modelContext.delete(taskItem)
            try? modelContext.save()
        }, cancelTitle: String(localized: "CANCEL"),cancelAction: {
            
        })
    }
    
}
