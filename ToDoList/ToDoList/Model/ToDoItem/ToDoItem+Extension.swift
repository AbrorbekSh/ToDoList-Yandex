//
//  ToDoItem+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation

extension ToDoItem {
    
//    static func map(from dto: ToDoItemDTO) -> ToDoItem {
//            guard let deadlineAt = dto.deadlineAt else {
//                return ToDoItem(
//                    text: dto.text,
//                    priority: Priority(rawValue: dto.importance) ?? .basic,
//                    isCompleted: dto.isDone,
//                    createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createdAt)),
//                    id: dto.id,
//                    deadline: nil,
//                    changedAt: Date(timeIntervalSince1970: TimeInterval(dto.changedAt))
//                )
//            }
//            
//            return ToDoItem(
//                text: dto.text,
//                priority: Priority(rawValue: dto.importance) ?? .basic,
//                isDone: dto.isDone,
//                createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createdAt)),
//                id: dto.id,
//                deadlineAt: Date(timeIntervalSince1970: TimeInterval(deadlineAt)),
//                changedAt: Date(timeIntervalSince1970: TimeInterval(dto.changedAt))
//            )
//        }
    
    static func map(dto: ToDoItemDTO) -> ToDoItem {
        if let deadline = dto.deadlineAt {
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
