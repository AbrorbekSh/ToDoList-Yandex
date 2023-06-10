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
    enum Priority: String {
        case lowPriority = "неважная"
        case regularPriority = "обычная"
        case highPriority = "важная"
    }
    var deadline: Data?
    var isCompleted: Bool = false
    var creationDate: Data
    var editDate: Date?
}
