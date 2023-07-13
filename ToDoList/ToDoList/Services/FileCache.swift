//
//  FileCache.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import Foundation
import SQLite

enum FileCacheError: Error {
    case failureDataToJson
    case failureParseTodoItem
    case failureCreatingDirectory
    case failureSaveTodoItem
    case alreadyExists
    case doesNotExist
    case notFound
}

public final class FileCache {
    private(set) var itemsJSON = [String:ToDoItem]()
    private(set) var items = [ToDoItem]()
    private var fileManager = FileManager.default
    private var database: Connection?
    
    // Define table structure
    let table = Table("ToDoItem")
    
    let id = Expression<String>("id")
    let text = Expression<String>("text")
    let priority = Expression<String>("priority")
    let deadline = Expression<Date?>("deadline")
    let isCompleted = Expression<Bool>("isCompleted")
    let createdAt = Expression<Date>("createdAt")
    let editedAt = Expression<Date?>("editedAt")
    let color = Expression<String?>("color")
    
    init() {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let fileUrl = documentDirectory.appending(path: "toDoList").appendingPathExtension("sqlite3")
            
            database = try Connection(fileUrl.path())
        } catch {
            print(error)
        }
    }
    
    func insert(item: ToDoItem) {
        guard let database = database else {
            return
        }
        let itemLine = table.insert(
                    id <- item.id,
                    text <- item.text,
                    priority <- item.priority.rawValue,
                    deadline <- item.deadline,
                    isCompleted <- item.isCompleted,
                    createdAt <- item.createdAt,
                    editedAt <- item.createdAt,
                    color <- item.color
        )
        
        do {
            try database.run(itemLine)
        } catch {
            print("Insertion error: \(error)")
        }
        items.append(item)
    }
    
    func load() -> [ToDoItem] {
        guard let database = database else {
            return []
        }
        do {
            let query = table.select([id, text, priority, deadline, isCompleted, createdAt, editedAt, color])
            for row in try database.prepare(query) {
                let item = ToDoItem(
                    id: row[id],
                    text: row[text],
                    priority: Priority(rawValue: row[priority]) ?? .basic,
                    deadline: row[deadline],
                    createdAt: row[createdAt],
                    editedAt: row[editedAt],
                    color: row[color] ?? "#00000"
                )
                items.append(item)
            }
        } catch {
            print("Query error: \(error)")
        }
        
        return items
    }
    
    func delete(idx: String) {
        guard let database = database else {
            return
        }
        
        let rowToDelete = table.filter(id == idx)
        let delete = rowToDelete.delete()
        do {
            let count = try database.run(delete)
        } catch {
            print("Deletion error: \(error)")
        }
        
        let index = items.firstIndex {
            $0.id == idx
        }
        if let index = index {
            items.remove(at: index)
        }
    }
}

//MARK: - FileCache for JSON
//Оставил для себя

extension FileCache {
    
    func deleteJSON(id: String) {
        itemsJSON.removeValue(forKey: id)
    }
    
    func addJSON(todoItem: ToDoItem) {
        if itemsJSON[todoItem.id] != nil {
            itemsJSON[todoItem.id] = todoItem
        } else {
            itemsJSON[todoItem.id] = todoItem
        }
    }
    
    func saveJSON(to dir: String) throws {
        let dirUrl = try getDirUrl(by: dir)
        try clearCache(by: dir)
        
        if !fileManager.fileExists(atPath: dirUrl.path) {
            try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        for todoItem in itemsJSON.values {
            try addToFile(todoItem: todoItem, to: dirUrl)
        }
    }
    
    func loadJSON(from dir: String) throws {
        let dirUrl = try getDirUrl(by: dir)

        guard let todoItemsId = try? getTodoItemsId(from: dirUrl) else {
            return
        }

        itemsJSON.removeAll()

        for id in todoItemsId {
            let todoItem = try getTodoItem(from: dirUrl, by: id)
            itemsJSON[todoItem.id] = todoItem
        }
    }
    
    func contains(todoItem: ToDoItem) -> Bool {
        itemsJSON.keys.contains(todoItem.id)
    }
    
    func clearCache(by name: String) throws {
        let dirUrl = try getDirUrl(by: name)
        
        if fileManager.fileExists(atPath: dirUrl.path) {
            try fileManager.removeItem(at: dirUrl)
        }
    }
    
    private func getDirUrl(by dir: String) throws -> URL {
        guard let cachesDirectoryUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw FileCacheError.alreadyExists
        }
        
        return cachesDirectoryUrl.appendingPathComponent(dir)
    }
    
    private func addToFile(todoItem: ToDoItem, to dir: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: todoItem.json, options: .fragmentsAllowed)
        let fileUrl = dir.appendingPathComponent("\(todoItem.id).json")
        try data.write(to: fileUrl)
    }
    
    private func getTodoItemsId(from dirUrl: URL) throws -> [String] {
        guard fileManager.fileExists(atPath: dirUrl.path),
              let todoItemsId = try? fileManager.contentsOfDirectory(atPath: dirUrl.path) else {
            throw FileCacheError.alreadyExists
        }
        
        return todoItemsId
    }
    
    private func getTodoItem(from dirUrl: URL, by id: String) throws -> ToDoItem {
        let fileUrl = dirUrl.appendingPathComponent("\(id)")
        let data = try Data(contentsOf: fileUrl)
        guard let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let todoItem = ToDoItem.parse(json: json) else {
            throw FileCacheError.failureParseTodoItem
        }
        
        return todoItem
    }
}


//MARK: - FileCache for CSV

extension FileCache {

    func saveCSV(to directory: String) throws {
        let urls = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        guard let cachesDirectoryUrl = urls.first else {
            throw FileCacheError.doesNotExist
        }
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory).csv")
        
        if !fileManager.fileExists(atPath: directoryUrl.path) {
            do {
                try fileManager.createDirectory(
                    at: directoryUrl,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                throw FileCacheError.failureCreatingDirectory
            }
        }
        
        let data = itemsJSON.map { _, item in
            item.csv
        }.reduce(into: ToDoItem.titles.joined(separator: ",")) {
            $0 += "\n" + $1
        }
        
        do {
            try data.write(to: directoryUrl, atomically: false, encoding: .utf8)
        } catch {
            throw FileCacheError.failureSaveTodoItem
        }
    }
    
    func loadCSV(from directory: String) throws {
        
        itemsJSON.removeAll()
        
        let urls = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        guard let cachesDirectoryUrl = urls.first else {
            throw FileCacheError.doesNotExist
        }
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory).csv")
        
        guard let data = try? String(contentsOf: directoryUrl) else {
            throw FileCacheError.doesNotExist
        }
        
        let titles = ToDoItem.titles.joined(separator: ",")
        for row in data.components(separatedBy: ",") where row != titles {
            guard let task = ToDoItem.parse(csv: row) else {
                continue
            }
            itemsJSON[task.id] = task
        }
    }
}
