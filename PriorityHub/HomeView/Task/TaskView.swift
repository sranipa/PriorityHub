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
    @State var viewModel : TaskViewModel = TaskViewModel()
    
    @Query(filter: #Predicate<TaskItem> { taskItem in
        !taskItem.isCompleted && !taskItem.isTaskDelete }) var tasks : [TaskItem]
    
    @State var isShowAddTask : Bool = false
    @State var isEditTaskItem : Bool = false
    @State var editTaskItem : TaskItem? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(String(localized: "NO_TASK_FOUND"), systemImage: "plus.app.fill", description: Text(String(localized: "CREATE_YOUR_FIRST_TASK")))
                        .buttonStyle(.borderedProminent)
                        .onTapGesture {
                            isShowAddTask.toggle()
                        }
                } else {
                    viewForTaskList
                        .searchable(text: $viewModel.searchText, prompt: String(localized: "SEARCH_TASK"))
                        .toolbar {
                            ToolbarItemGroup(placement: .topBarTrailing, content: {
                                    Menu {
                                        Picker("SORT_BY", selection: $viewModel.sortOption) {
                                            ForEach(TaskViewModel.sortOptions.allCases, id: \.self) { sortOption in
                                                Text(sortOption.rawValue)
                                                    .tag(sortOption)
                                            }
                                        }
                                    } label: {
                                        Label("SORT_BY", systemImage: "line.3.horizontal.decrease.circle")
                                    }
                                    
                                    Button {
                                    
                                    } label: {
                                        Label("Filter", systemImage: "slider.vertical.3")
                                    }
                            })
                        }
                }
            }
            .sheet(item: $editTaskItem, content: { taskItem in
                AddTaskView(viewModel: AddTaskViewModel(modelContext: modelContext,isFromEdit: true,editTaskItem: taskItem))
            })
            .sheet(isPresented: $isShowAddTask, content: {
                AddTaskView(viewModel: AddTaskViewModel(modelContext: modelContext))
            })
        }
    }
    
    var viewForTaskList : some View {
        List {
            ForEach(viewModel.getGroupedTask(tasks: tasks), id: \.header) { group in
                Section {
                    ForEach(group.tasks) { task in
                        getRowView(task: task)
                    }
                } header: {
                    Text(group.header)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
        }.listStyle(.insetGrouped)
    }
    //MARK: -
    //MARK: - Design For Row
    @ViewBuilder
    func getRowView(task:TaskItem) -> some View {
        VStack(spacing:3){
            HStack {
                Text(task.title)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "flag.fill")
                    .foregroundStyle(Color(PriorityLevel(rawValue: task.priorityLevel)?.color ?? .gray))
            }
            
            HStack {
                Text(task.notes)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                
                Spacer()
                
                Text(".\(task.project?.name ?? "")")
                    .font(.caption)
            }
            
            if viewModel.sortOption != .dueDate {
                HStack {
                    Text(String(localized: "DUE_DATE") + " : " + getDate(date: task.dueDate))
                        .font(.caption2)
                    
                    Spacer()
                }
            }
        }
        .id(task.id)
        .swipeActions(edge:.trailing, allowsFullSwipe: false) {
            Button(){
                viewModel.onDelete(modelContext: modelContext, taskItem: task)
            } label: {
                Label("DELETE", systemImage: "trash")
            }.tint(.red)
            
            Button() {
                viewModel.onComplete(modelContext: modelContext, taskItem: task)
            } label: {
                Label("COMPLETE", systemImage: "checkmark.circle")
            }.tint(.green)
            
            Button(){
                editTaskItem = task
                isEditTaskItem.toggle()
            } label: {
                Label("EDIT", systemImage: "square.and.pencil")
            }.tint(.blue)
        }
    }
}

#Preview {
    TaskView()
}
