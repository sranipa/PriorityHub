//
//  TaskViewModelTest.swift
//  PriorityHubTests
//
//  Created by Sapana Bhorania on 5/12/26.
//

import Foundation
import XCTest
import SwiftData
@testable import PriorityHub

@MainActor
final class TaskViewModelTest: XCTestCase {
    
    var context : ModelContext!
    
    override func setUp() {
        super.setUp()
        
        // Use the in-memory container for every test
        context = TestDatabaseContainer.container.mainContext
    }
    
    override func tearDown() {
        context = nil
    }
    
    func test_SaveTask() {
        // Arrange
        let newTask = TaskItem(title: "Test1", ownerId: "Abc")
        
        //Act
        context.insert(newTask)
        try? context.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedTask = try? context.fetch(descriptor)
        
        //Assert
        XCTAssertEqual(fetchedTask?.count, 1)
        XCTAssertEqual(fetchedTask?.first?.title, "Test1")
        
    }
    
    func test_TaskSorting_HighPriority_ShouldBeFirst(){
        //Arrange
        let highPriorityTask = TaskItem(title: "High", priorityLevel: 2, ownerId: "Abc")
        let lowPriorityTask = TaskItem(title: "Low", priorityLevel: 0, ownerId: "Abc")
        
        context.insert(highPriorityTask)
        context.insert(lowPriorityTask)
        
        // Act
        let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.priorityLevel, order: .forward)])
        let taskItems = try? context.fetch(descriptor)
        
        // Assert
        
        XCTAssertEqual(taskItems?.count, 2)
        XCTAssertEqual(taskItems?.first?.title, "Low")
        XCTAssertEqual(taskItems?.last?.title, "High")
        
    }
}

struct TestDatabaseContainer {
    static let container : ModelContainer = {
        do {
            let container = try ModelContainer(for: TaskItem.self, Project.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            // "isStoredInMemoryOnly: true" is the secret sauce! - Which store data into RAM
            return container
        } catch {
            fatalError("Failed to create testable database model container")
        }
    }()
}
