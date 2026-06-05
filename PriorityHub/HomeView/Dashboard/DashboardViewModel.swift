//
//  DashboardViewModel.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 6/3/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class DashboardViewModel {
    func getTaskCount(allTasks: [TaskItem], forPriority: PriorityLevel) -> Int {
        return allTasks.filter{ task in
            Calendar.current.isDateInToday(task.dueDate) &&
            task.priorityLevel == forPriority.rawValue &&
            !task.isCompleted
        }.count
    }
    func getLastSevenDaysData(allTasks: [TaskItem]) -> [dailyDataForGraph] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        let lastSevenDays = (-6...0).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
        
        guard let startDate = lastSevenDays.first else { return [] }
        
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else { return []}
        
        let filteredTasks = allTasks.filter({
            $0.isCompleted &&
            $0.dueDate >= startDate &&
            $0.dueDate < endDate })
        
        let groupedTasks = Dictionary(grouping: filteredTasks, by: { calendar.startOfDay(for: $0.dueDate) })
        
        let formate = Date.FormatStyle().weekday(.abbreviated)
        
        return lastSevenDays.map { date in
            let day = date.formatted(formate)
            let count = groupedTasks[date]?.count ?? 0
            return dailyDataForGraph(day: day, count: count)
        }
    }
}
// For graph we require 
struct dailyDataForGraph : Identifiable {
    var id : UUID = UUID()
    var day : String
    var count : Int
}
