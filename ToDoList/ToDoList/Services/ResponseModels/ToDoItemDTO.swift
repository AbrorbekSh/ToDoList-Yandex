//
//  ToDoItemDTO.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation
import UIKit

struct ToDoItemDTO: Codable {
    let id: String
    let text: String
    let importance: String
    let deadlineAt: Int?
    let isDone: Bool
    let createdAt: Int
    let changedAt: Int
    let color: String?
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadlineAt = "deadline"
        case isDone = "done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case color
        case deviceId = "last_updated_by"
    }
    
    init(from todoItem: ToDoItem) {
        self.id = todoItem.id
        self.text = todoItem.text
        self.importance = todoItem.priority.rawValue
        self.deadlineAt = todoItem.deadline.flatMap { Int($0.timeIntervalSince1970) }
        self.isDone = todoItem.isCompleted
        self.createdAt = Int(todoItem.createdAt.timeIntervalSince1970)
        self.changedAt = Int((todoItem.editedAt ?? todoItem.createdAt).timeIntervalSince1970)
        self.color = todoItem.color
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}
