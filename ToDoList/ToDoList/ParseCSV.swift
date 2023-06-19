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
        } else {
            csvString += ",-"
        }
        
        if let deadlineTimestamp = deadline?.timeIntervalSince1970 {
            csvString += ",\(deadlineTimestamp)"
        } else {
            csvString += ",-"
        }
        
        csvString += ",\(isCompleted)"
        
        if let editedAtTimestamp = editedAt?.timeIntervalSince1970 {
            csvString += ",\(editedAtTimestamp)"
        } else {
            csvString += ",-"
        }
        
        return csvString
    }
}

extension ToDoItem {
    private init?(with parsedCSV: [String]) {
        if parsedCSV.count < 7 {
            return nil
        }
        
        let id = parsedCSV[0]
        
        let text = parsedCSV[1]
        
        guard let createdAt = (Double(parsedCSV[2]).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }) else { return nil }
        
        var priority: Priority
        
        switch parsedCSV[3] {
        case "low":
            priority = .low
            
        case "high":
            priority = .high
            
        default:
            priority = .basic
        }
        
        let deadline = (Double(parsedCSV[4]).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        })
        
        var isCompleted = false
        
        if parsedCSV[5] == "true" {
            isCompleted = true
        }

        let editedAt = (Double(parsedCSV[6]).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        })
        
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


