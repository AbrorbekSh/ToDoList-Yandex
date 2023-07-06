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
    let deadline: Int?
    let isDone: Bool
    let createdAt: Int
    let changedAt: Int
    let color: String?
    let deviceId: String

    init(from toDoItem: ToDoItem) {
        self.id = toDoItem.id
        self.text = toDoItem.text
        self.importance = toDoItem.priority.rawValue
        self.deadline = toDoItem.deadline.flatMap { Int($0.timeIntervalSince1970) }
        self.isDone = toDoItem.isCompleted
        self.createdAt = Int(toDoItem.createdAt.timeIntervalSince1970)
        self.changedAt = Int((toDoItem.editedAt ?? toDoItem.createdAt).timeIntervalSince1970)
        self.color = toDoItem.color
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline = "deadline"
        case isDone = "done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case color
        case deviceId = "last_updated_by"
    }
}
