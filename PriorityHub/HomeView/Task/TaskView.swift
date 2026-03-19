//
//  TaskView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/11/26.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var tasks : [TaskItem]
    
    @State var isShowAddTask : Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView("No Tasks Found", systemImage: "plus.app.fill", description: Text("Create your first task."))
                        .buttonStyle(.borderedProminent)
                        .onTapGesture {
                            isShowAddTask.toggle()
                        }
                } else {
                    viewForTaskList
                }
            }
            .sheet(isPresented: $isShowAddTask, content: {
                AddTaskView(viewModel: AddTaskViewModel(modelContext: modelContext))
            })
//            .fullScreenCover(isPresented: $isShowAddTask) {
//                AddTaskView()
//            }
        }
    }
    var viewForTaskList : some View {
        VStack {
            List(tasks) { task in
                Text(task.title)
            }
        }
    }
}

#Preview {
    TaskView()
}
