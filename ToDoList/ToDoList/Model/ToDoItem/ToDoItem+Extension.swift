//
//  ToDoItem+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation

extension ToDoItem {
    static func convertFromDTO(dto: ToDoItemDTO) -> ToDoItem {
        if let deadline = dto.deadline {
            return ToDoItem(id: dto.id,
                            text: dto.text,
                            priority: Priority(rawValue: dto.importance) ?? .basic,
                            deadline: Date(timeIntervalSince1970: TimeInterval(deadline)),
                            isCompleted: dto.isDone,
                            createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createdAt)),
                            editedAt: Date(timeIntervalSince1970: TimeInterval(dto.changedAt)),
                            color: dto.color ?? "#FFFFFF"
            )
        }
        return ToDoItem(id: dto.id,
                        text: dto.text,
                        priority: Priority(rawValue: dto.importance) ?? .basic,
                        deadline: nil,
                        isCompleted: dto.isDone,
                        createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createdAt)),
                        editedAt: Date(timeIntervalSince1970: TimeInterval(dto.changedAt)),
                        color: dto.color ?? "#FFFFFF"
            )
    }
}
