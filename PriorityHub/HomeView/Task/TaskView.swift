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
    
    @Query(filter: #Predicate<TaskItem> { taskItem in
        taskItem.isCompleted == false
    }, sort: [SortDescriptor(\TaskItem.dueDate)]) var tasks : [TaskItem]
    
    // Group tasks by the date component only (ignoring time)
    var groupedTasks : [(date:Date, tasks:[TaskItem])] {
        
        // 1. Group the raw tasks into a Dictionary [Date: [TodoTask]]
        let groupedDictionary = Dictionary(grouping: tasks) { task in
            Calendar.current.startOfDay(for: task.dueDate)
        }
        
        // 2. Sort the keys (Dates) and transform into a named Tuple array
        return groupedDictionary
            .sorted(by: { first, second in
                first.key < second.key
            }) // Sorts by oldest date to newest
            .map { (date:$0.key, tasks:$0.value)} // Labels the data for the View
    }
    
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
//    var viewForTaskList : some View {
//        VStack {
//            List(tasks) { task in
//                Text(task.title)
//            }
//        }
//    }
    var viewForTaskList : some View {
        List {
            ForEach(groupedTasks, id: \.date) { group in
                Section {
                    ForEach(group.tasks) { task in
                        VStack(spacing:3){
                            HStack {
                                Text(task.title)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                Text(".\(task.project?.name ?? "")")
                                    .font(.caption)
                            }
                        }
                    }
                } header: {
                    Text(getDate(date: group.date))
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
        }.listStyle(.insetGrouped)
    }
}

#Preview {
    TaskView()
}
