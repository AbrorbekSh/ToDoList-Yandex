//
//  FileCache.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import Foundation

enum FileCacheError: Error {
    case failureDataToJson
    case failureParseTodoItem
    case failureCreatingDirectory
    case failureSaveTodoItem
    case alreadyExists
    case doesNotExist
    case notFound
}

final class FileCache {
    private(set) var items = [String:ToDoItem]()
    private var fileManager = FileManager.default
    
    func add(todoItem: ToDoItem) {
        if items[todoItem.id] != nil {
            items[todoItem.id] = todoItem
        } else {
            items[todoItem.id] = todoItem
        }
    }
    
    func delete(id: String) {
        items.removeValue(forKey: id)
    }
        
}

//MARK: - FileCache for JSON

extension FileCache {
    func save(to dir: String) throws {
        let dirUrl = try getDirUrl(by: dir)
        try clearCache(by: dir)
        
        if !fileManager.fileExists(atPath: dirUrl.path) {
            try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        for todoItem in items.values {
            try addToFile(todoItem: todoItem, to: dirUrl)
        }
    }
    
    func load(from dir: String) throws {
        let dirUrl = try getDirUrl(by: dir)
        
        guard let todoItemsId = try? getTodoItemsId(from: dirUrl) else {
            return
        }
        
        items.removeAll()
        
        for id in todoItemsId {
            let todoItem = try getTodoItem(from: dirUrl, by: id)
            items[todoItem.id] = todoItem
        }
    }
    
    func contains(todoItem: ToDoItem) -> Bool {
        items.keys.contains(todoItem.id)
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
        
        let data = items.map { _, item in
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
        
        items.removeAll()
        
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
            items[task.id] = task
        }
    }
}
