//
//  InsightsView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/11/26.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    
    @Query(filter: #Predicate<TaskItem>{ $0.isCompleted == true }) var completedTasks : [TaskItem]
    
    var body: some View {
        NavigationStack {
            List {
                Section("WEEKLY_PROGRESS") {
                    VStack(alignment: .leading) {
                        let velocityStatus = completedTasks.completionVelocity()
                        
                        HStack(spacing: 10){
                            Text("\(velocityStatus.thisWeekCount) Tasks")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Text(String(format: "%0.f%% %@", abs(velocityStatus.percentageChange), velocityStatus.percentageChange > 0 ? "up" : "down"))
                                .font(.caption)
                                .padding(.horizontal,10)
                                .padding(.vertical,5)
                                .background(velocityStatus.percentageChange > 0 ? .green.opacity(0.2) : .red.opacity(0.2))
                                .foregroundStyle(velocityStatus.percentageChange > 0 ? .green : .red)
                                .clipShape(.capsule)
                            
                            Spacer()
                        }
                        
                        Text("vs \(velocityStatus.lastWeekCount) last week")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Chart(completedTasks) { task in
                            BarMark(x: .value("completedAt", task.completedAt ?? Date(), unit: .day),
                                    y: .value("count", 1))
                            .foregroundStyle(.blue.gradient)
                        }
                        .chartYAxis(content: {
                            AxisMarks(position: .leading)
                        })
                        .frame(height: 200)
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("INSIGHTS")
        }
    }
}
#Preview {
    InsightsView()
}

extension Array where Element == TaskItem {
    
    func completedTaskInRange(start:Date, end:Date) -> [TaskItem] {
        return self.filter { task in
            guard let completedDate = task.completedAt else { return false }
            return completedDate >= start && completedDate <= end
        }
    }
    
    func completionVelocity() -> (thisWeekCount: Int, lastWeekCount: Int, percentageChange: Double) {
        let calendar = Calendar.current
        let now = Date()
        
        guard let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
              let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart) else { return (0, 0, 0)}
        
        let thisWeekCount : Int = completedTaskInRange(start: thisWeekStart, end: .now).count
        let lastWeekCount : Int = completedTaskInRange(start: lastWeekStart, end: thisWeekStart).count
        
        // Calculate Percentage Changes
        if lastWeekCount == 0 {
            return (thisWeekCount, lastWeekCount, thisWeekCount > 0 ? 100 : 0)
        }
        
        let change = (Double(thisWeekCount - lastWeekCount) / Double(lastWeekCount)) * 100
        return(thisWeekCount,lastWeekCount,change)
    }
}
