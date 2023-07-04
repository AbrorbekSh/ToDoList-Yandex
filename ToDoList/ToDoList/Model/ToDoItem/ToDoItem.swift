//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import Foundation

public struct ToDoItem: Equatable {
    let id: String
    let text: String
    let priority: Priority
    let deadline: Date?
    let isCompleted: Bool
    let createdAt: Date
    let editedAt: Date?
    let color: String
    
    static let titles = ["id", "text", "createdAt", "priority", "deadline", "isCompleted", "editedAt"]
    
    init(id: String = UUID().uuidString,
         text: String,
         priority: Priority,
         deadline: Date? = nil,
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         editedAt: Date? = nil,
         color: String = "#000000"
    )
    {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.editedAt = editedAt
        self.color = color
    }
    
    public static func ==(lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.text == rhs.text &&
                lhs.priority == rhs.priority &&
                lhs.isCompleted == rhs.isCompleted &&
                lhs.deadline?.timeIntervalSince1970 == rhs.deadline?.timeIntervalSince1970 &&
                lhs.createdAt.timeIntervalSince1970 == rhs.createdAt.timeIntervalSince1970 &&
                lhs.editedAt?.timeIntervalSince1970 == rhs.editedAt?.timeIntervalSince1970
    }
}


