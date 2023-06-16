//
//  ParseJSON.swift
//  ToDoList
//
//  Created by Аброрбек on 11.06.2023.
//

import Foundation

extension ToDoItem {
    static func parse(json: Any) -> ToDoItem? {
        guard let jsonDictionary = json as? [String: Any] else { return nil }
        return ToDoItem(with: jsonDictionary)
    }
    
    var json: Any {
        var jsonDictionary: [String: Any] = [
            "id": id,
            "text": text,
            "isCompleted": isCompleted,
            "createdAt": createdAt.timeIntervalSince1970
        ]
        
        if priority != .basic {
            jsonDictionary["priority"] = priority.rawValue
        }
        
        if let deadline = deadline {
            jsonDictionary["deadline"] = deadline.timeIntervalSince1970
        }
        
        if let editedAt = editedAt {
            jsonDictionary["editedAt"] = editedAt.timeIntervalSince1970
        }
        
        return jsonDictionary
    }
}

extension ToDoItem {
    private init?(with jsonDictionary: [String: Any]) {
        guard
            let id = jsonDictionary["id"] as? String,
            let text = jsonDictionary["text"] as? String,
            let createdAt = ((jsonDictionary["createdAt"] as? Double).flatMap {
                Date(timeIntervalSince1970: TimeInterval($0))
            }) else {
                return nil
            }
        
        let isCompleted = jsonDictionary["isCompleted"] as? Bool ?? false
        let priority = (jsonDictionary["priority"] as? String).flatMap(Priority.init) ?? .basic
        
        let editedAt = (jsonDictionary["editedAt"] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }
        let deadline = (jsonDictionary["deadline"] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }
        
        self.init(
            id: id,
            text: text,
            priority: priority,
            deadline: deadline,
            isCompleted: isCompleted,
            createdAt: createdAt,
            editedAt: editedAt
        )
    }
}
