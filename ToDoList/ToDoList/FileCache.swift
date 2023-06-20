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
}

final class FileCache {
    
    private(set) var tasks = [String:ToDoItem]()
    private var fileManager = FileManager.default
    
    func add(task: ToDoItem) -> ToDoItem? {
        let prevItem = tasks[task.id]
        tasks[task.id] = task
        return prevItem
    }
    
    func delete(id: String) -> ToDoItem? {
        let prevItem = tasks[id]
        tasks[id] = nil
        return prevItem
    }
}

//MARK: - FileCache for JSON

extension FileCache {
    
    func saveJSON(to directory: String) throws {
        let urls = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        guard let cachesDirectoryUrl = urls.first else {
            throw FileCacheError.doesNotExist
        }
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory).json")
        
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
        let serializedItems = tasks.map { _, task in task.json }
        let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
        try data.write(to: directoryUrl)
    }
    
    func loadJSON(from directory: String) throws {
        
        tasks.removeAll()
        
        let urls = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        guard let cachesDirectoryUrl = urls.first else {
            throw FileCacheError.doesNotExist
        }
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory).json")
        
        guard let data = try? Data(contentsOf: directoryUrl) else {
            throw FileCacheError.doesNotExist
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw FileCacheError.doesNotExist
        }
        let deserializedItems = json.compactMap { ToDoItem.parse(json: $0) }
        tasks = deserializedItems.reduce(into: [:]) { res, item in
            res[item.id] = item
        }
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
        
        let data = tasks.map { _, item in
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
        
        tasks.removeAll()
        
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
            tasks[task.id] = task
        }
    }
}
