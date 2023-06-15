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
    
    func add(task: ToDoItem) throws {
        if tasks[task.id] == nil {
            tasks[task.id] = task
        } else {
            throw FileCacheError.alreadyExists
        }
    }
    
    func delete(id: String) throws {
        if tasks[id] != nil {
            tasks[id] = nil
        } else {
            throw FileCacheError.doesNotExist
        }
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
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory)")
        
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
        
        for toDoItem in tasks.values {
            do {
                guard let data = try? JSONSerialization.data(
                    withJSONObject: toDoItem.json,
                    options: .fragmentsAllowed
                ) else {
                    throw FileCacheError.failureDataToJson
                }
                
                let fileUrl = directoryUrl.appendingPathComponent("\(toDoItem.id).json")
                
                guard (try? data.write(to: fileUrl)) != nil else {
                    throw FileCacheError.failureSaveTodoItem
                }
            } catch FileCacheError.failureSaveTodoItem {
                throw FileCacheError.failureSaveTodoItem
            }
        }
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
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory)")
        
        guard fileManager.fileExists(atPath: directoryUrl.path),
              let toDoItemsId = try? fileManager.contentsOfDirectory(atPath: directoryUrl.path) else {
                  throw FileCacheError.doesNotExist
              }

        
        for id in toDoItemsId {
            let fileUrl = directoryUrl.appendingPathComponent("\(id).json")
            guard let data = try? Data(contentsOf: fileUrl) else {
                throw FileCacheError.doesNotExist
            }
            
            guard let json = try? JSONSerialization.jsonObject(
                with: data,
                options: .fragmentsAllowed
            ) else {
                throw FileCacheError.failureDataToJson
            }
            
            guard let toDoItem = ToDoItem.parse(json: json) else {
                throw FileCacheError.failureParseTodoItem
            }
            
            tasks[toDoItem.id] = toDoItem
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
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory)")
        
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
        
        for toDoItem in tasks.values {
            
            let csvString = toDoItem.csv
            
            let fileUrl = directoryUrl.appendingPathComponent("\(toDoItem.id).csv")
            
            do {
                try csvString.write(to: fileUrl, atomically: true, encoding: .utf8)
            } catch {
                throw FileCacheError.failureSaveTodoItem
            }
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
        
        let directoryUrl = cachesDirectoryUrl.appendingPathComponent("\(directory)")
        
        guard fileManager.fileExists(atPath: directoryUrl.path),
              let toDoItemsId = try? fileManager.contentsOfDirectory(atPath: directoryUrl.path) else {
                  throw FileCacheError.doesNotExist
              }

        
        for id in toDoItemsId {
            let fileUrl = directoryUrl.appendingPathComponent("\(id).csv")
            
            var csvString = ""
            
            do {
                csvString = try String(contentsOf: fileUrl, encoding: .utf8)
            } catch {
                throw FileCacheError.doesNotExist
            }
            
            guard let toDoItem = ToDoItem.parse(csv: csvString) else {
                throw FileCacheError.failureParseTodoItem
            }
            
            tasks[toDoItem.id] = toDoItem
        }
    }
}
