//
//  HomeView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/10/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(GlobalObject.self) var globalObject
    @State var isShowingAddTask : Bool = false
    var body: some View {
        @Bindable var globalObject = globalObject
         
        ZStack(alignment: .bottom) {
            TabView(selection: $globalObject.selectedTab) {
                
                DashboardView()
                    .tabItem {  Label("DASHBOARD", systemImage: "house.fill") }
                    .tag(0)
                
                TaskView()
                    .tabItem {  Label("TASKS", systemImage: "checklist") }
                    .tag(1)
                
                InsightsView()
                    .tabItem {  Label("INSIGHTS", systemImage: "chart.bar.fill") }
                    .tag(2)
                
                ProfileView()
                    .tabItem {  Label("PROFILE", systemImage: "person.circle") }
                    .tag(3)
            }
            
            Button {
                isShowingAddTask.toggle()
            } label: {
                Image(systemName: "plus")
                            .font(.title.bold())
                            .foregroundColor(.blue)
                            .padding()
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
            }
            .offset(y: -20)
            
        }
        .task {
            await syncAllDataWithFirebase()
        }
        .sheet(isPresented: $isShowingAddTask, content: {
            AddTaskView(viewModel: AddTaskViewModel(modelContext: modelContext))
        })
//        .fullScreenCover(isPresented: $isShowingAddTask) {
//            AddTaskView()
//        }
    }
    
    //MARK: -
    //MARK: - Syncing all SwiftData With Firebase
    func syncAllDataWithFirebase() async {
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

#Preview {
    HomeView()
}
