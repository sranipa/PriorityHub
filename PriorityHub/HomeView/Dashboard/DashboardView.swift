//
//  DashboardView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/11/26.
//

import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    
    @Query(filter: #Predicate<TaskItem> { item in !item.isTaskDelete }) var tasks : [TaskItem]
    @State var viewModel : DashboardViewModel = DashboardViewModel()
    @Environment(GlobalObject.self) var globalObject
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    viewForHeader
                    
                    viewForRemainingTasks
                    
                    viewForChart
                }
                .padding(.vertical)
            }.navigationTitle("DASHBOARD")
        }
        .onAppear {
            let result = viewModel.getLastSevenDaysData(allTasks: tasks)
            print(result.count)
        }
    }
    
    var viewForChart : some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5){
                Text("PRODUCTIVITY_VELOCITY")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text("COMPLETED_ASSIGNMENT_OVER_THE_PAST_SEVEN_DAYS")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                Chart(viewModel.getLastSevenDaysData(allTasks: tasks)) { dayData in
                    BarMark(x:.value("Day", dayData.day), y: .value("Completed Task", dayData.count))
                        .cornerRadius(5)
                }
                .chartYAxis(content: {
                    AxisMarks(position: .leading)
                })
                .frame(height:200)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    var viewForRemainingTasks : some View {
        VStack(alignment: .leading) {
            HStack {
                Text("REMAINING_TASKS_DUE_TODAY")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            HStack(spacing: 8) {
                cardView(priority: .high, count: viewModel.getTaskCount(allTasks: tasks, forPriority: .high))
                
                cardView(priority: .medium, count: viewModel.getTaskCount(allTasks: tasks, forPriority: .medium))
                
                cardView(priority: .low, count: viewModel.getTaskCount(allTasks: tasks, forPriority: .low))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    var viewForHeader : some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                
                Text("TODAY_OVERVIEW")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
}

struct cardView : View {
    @Environment(GlobalObject.self) var globalObject
    var priority : PriorityLevel
    var count : Int
    
    var body: some View {
        VStack(alignment: .leading, spacing:10) {
            HStack(alignment: .firstTextBaseline) {
                switch priority {
                case .low:
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundStyle(priority.color)
                case .medium:
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(priority.color)
                case .high:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(priority.color)
                }
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(count > 0 ? .primary : .secondary)
                
            }
            
            Text(priority.label)
                .foregroundStyle(.secondary)
                .textInputAutocapitalization(.words)
                .font(.caption)
                .fontWeight(.bold)
            
        }
        .padding(.all)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(count > 0 ? priority.color.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .onTapGesture {
            if count > 0 {
                globalObject.selectedTab = 1
            }
        }
    }
}
