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
    @State private var viewModel = HomeViewModel()
    
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
                viewModel.isShowingAddTask.toggle()
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
        .task(id: globalObject.firebaseUserId) {
            if let uid = globalObject.firebaseUserId {
                await viewModel.syncAllDataWithFirebase(modelContext: modelContext, uid: uid)
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddTask, content: {
            AddTaskView(viewModel: AddTaskViewModel(modelContext: modelContext))
        })
//        .fullScreenCover(isPresented: $isShowingAddTask) {
//            AddTaskView()
//        }
    }
}

#Preview {
    HomeView()
}
