//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Аброрбек on 10.07.2023.
//

import Foundation
import CoreData

final class FileCacheService {
    
    private var toDoItemsCD: [ToDoItemCore] = []
    private(set) var items: [ToDoItem] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "ToDoItem")
        persistentContainer.loadPersistentStores { _, error in
            print(error?.localizedDescription ?? "")
        }
        return persistentContainer
    }()
    
    var moc: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func insert(item: ToDoItem) {
        let itemToInsert = ToDoItemCore(context: moc)
        setValues(to: itemToInsert, with: item)
        toDoItemsCD.append(itemToInsert)
        items.append(item)
        save()
    }
    
    func delete(item: ToDoItem) {
        if let index = toDoItemsCD.firstIndex(where: { $0.id == item.id }) {
            moc.delete(toDoItemsCD[index])
            toDoItemsCD.remove(at: index)
        }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        save()
    }
    
    func update(item: ToDoItem) {
        if let index = toDoItemsCD.firstIndex(where: { $0.id == item.id }) {
            moc.delete(toDoItemsCD[index])
            toDoItemsCD.remove(at: index)
            let itemToUpdate = ToDoItemCore(context: moc)
            setValues(to: itemToUpdate, with: item)
            toDoItemsCD.append(itemToUpdate)
            
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            }
        }
        save()
    }
    
    func save(){
        do {
            try moc.save()
        } catch {
            print("Can not save the item")
        }
    }
    
    func load() -> [ToDoItem] {
        do {
            let fetchRequest = NSFetchRequest<ToDoItemCore>(entityName: "ToDoItemCore")
            toDoItemsCD = try moc.fetch(fetchRequest)
            
            items = []
            for itemCore in toDoItemsCD {
                items.append(try ToDoItem(from: itemCore))
            }
            return items
        } catch {
            print(error)
            return []
        }
    }
    
    func setValues(to itemToSave: NSManagedObject, with item: ToDoItem) {
        itemToSave.setValue(item.id, forKeyPath: Key.id)
        itemToSave.setValue(item.text, forKeyPath: Key.text)
        itemToSave.setValue(item.priority.rawValue, forKeyPath: Key.priority)
        itemToSave.setValue(item.isCompleted, forKeyPath: Key.isCompleted)
        itemToSave.setValue(item.deadline, forKeyPath: Key.deadline)
        itemToSave.setValue(item.editedAt, forKeyPath: Key.editedAt)
        itemToSave.setValue(item.createdAt, forKeyPath: Key.createdAt)
        itemToSave.setValue(item.color, forKeyPath: Key.color)
    }
    
    enum Key {
        static let id = "id"
        static let text = "text"
        static let priority = "priority"
        static let deadline = "deadline"
        static let isCompleted = "isCompleted"
        static let createdAt = "createdAt"
        static let editedAt = "editedAt"
        static let color = "color"
    }
}
