//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import Foundation

struct ToDoItem {
    var id = UUID().uuidString
    var text: String
    var priority: Priority
    var deadline: Date?
    var isCompleted: Bool = false
    var createdAt: Date
    var editedAt: Date?
    
    init(id: String = UUID().uuidString,
         text: String,
         priority: Priority,
         deadline: Date? = nil,
         isCompleted: Bool,
         createdAt: Date,
         editedAt: Date? = nil)
    {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}


