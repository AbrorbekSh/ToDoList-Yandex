//
//  ParseCSV.swift
//  ToDoList
//
//  Created by Аброрбек on 14.06.2023.
//

import Foundation

extension ToDoItem {
    static func parse(csv: String) -> ToDoItem? {
        let parsedCSV: [String] = csv.components(
            separatedBy: ","
        )
        
        return ToDoItem(with: parsedCSV)
    }
    
    var csv: String {
        var csvString = "\(id),\(text),\(createdAt.timeIntervalSince1970)"
        
        if priority != .basic {
            csvString += ",\(priority.rawValue)"
        }
        
        if let deadlineTimestamp = deadline?.timeIntervalSince1970 {
            csvString += ",\(deadlineTimestamp)"
        }
        
        csvString += ",\(isCompleted)"
        
        if let editedAtTimestamp = editedAt?.timeIntervalSince1970 {
            csvString += ",\(editedAtTimestamp)"
        }
        
        return csvString
    }
}

extension ToDoItem {
    private init?(with parsedCSV: [String]) {
        if parsedCSV.count < 4 {
            return nil
        }
        
        let id = parsedCSV[0]
        
        let text = parsedCSV[1]
        
        guard let createdAt = (Double(parsedCSV[2]).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }) else { return nil }
        
        var index = 3 // to keep the order
        
        var priority: Priority
        
        switch parsedCSV[index] {
            
        case "low":
            priority = .low
            index += 1
            
        case "high":
            priority = .high
            index += 1
            
        default:
            priority = .basic
        }
        
        let deadline = (Double(parsedCSV[index]).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        })
        
        if deadline != nil {
            index += 1
        }
        
        var isCompleted = false
        
        if parsedCSV[index] == "true" {
            isCompleted = true
        }
        
        index += 1
        
        var editedAt: Date? = nil
        if index < parsedCSV.count {
            editedAt = (Double(parsedCSV[index]).flatMap {
                Date(timeIntervalSince1970: TimeInterval($0))
            })
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


