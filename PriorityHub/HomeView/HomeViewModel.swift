//
//  HomeViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 4/23/26.
//

import Foundation
import SwiftData

@Observable
class HomeViewModel {
    
    var isShowingAddTask : Bool = false
    
    //MARK: -
    //MARK: - Syncing all SwiftData With Firebase
    func syncAllDataWithFirebase(modelContext: ModelContext) async {
        let firebaseService = syncUnsyncFirebase.init(modelContext: modelContext)
        let uid = getFirebaseUserID()
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await firebaseService.uploadAllTasks()
            }
            group.addTask {
                await firebaseService.deleteTasks()
            }
            group.addTask {
                await firebaseService.listenerForTaskChanges(userId: uid)
            }
            group.addTask {
                await firebaseService.uploadAllProjects()
            }
            group.addTask {
                await firebaseService.listenerForProjectChanges(userId: uid)
            }
        }
    }
}
