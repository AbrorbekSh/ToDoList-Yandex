//
//  ToDoItem+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 10.07.2023.
//

import Foundation
import CoreData

extension ToDoItem {
    enum TodoItemError: Error {
        case failureParseNSManagedObject
    }
    
    init(from managedObject: NSManagedObject) throws {
        guard
            let text = managedObject.value(forKey: FileCacheService.Key.text) as? String,
            let priorityString = managedObject.value(forKey: FileCacheService.Key.priority) as? String,
            let priority = Priority(rawValue: priorityString),
            let isCompleted = managedObject.value(forKey: FileCacheService.Key.isCompleted) as? Bool,
            let createdAt = managedObject.value(forKey: FileCacheService.Key.createdAt) as? Date,
            let id = managedObject.value(forKey: FileCacheService.Key.id) as? String,
            let deadline = managedObject.value(forKey: FileCacheService.Key.deadline) as? Date?,
            let editedAt = managedObject.value(forKey: FileCacheService.Key.editedAt) as? Date?,
            let color = managedObject.value(forKey: FileCacheService.Key.color) as? String?
        else {
              throw TodoItemError.failureParseNSManagedObject
            }
        self.init(
            id: id,
            text: text,
            priority: priority,
            deadline: deadline,
            isCompleted: isCompleted,
            createdAt: createdAt,
            editedAt: editedAt,
            color: color ?? "#00000"
        )
    }
}
