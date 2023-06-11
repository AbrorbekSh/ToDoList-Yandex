//
//  FileCache.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import Foundation

class FileCash {
    private(set) var tasks: Set<ToDoItem> = []
    
    func addNewTask(task: ToDoItem){
        for item in tasks {
            if item.id == task.id {
                return
            }
        }
        
        tasks.insert(task)
    }
    
    func deleteTask(id: String){
        for task in tasks {
            if task.id == id {
                tasks.remove(task)
                break
            }
        }
    }
}
