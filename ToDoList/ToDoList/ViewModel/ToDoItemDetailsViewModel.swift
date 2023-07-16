//
//  ToDoItemDetailsViewModel.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import Foundation
import CoreData

protocol ItemDetailsDelegate: AnyObject {
    func changesAppeared()
}

final class ToDoItemDetailsViewModel {
    
    private let fileCacheService: FileCacheService
    private let networkingService: NetworkingService
    
    weak var coordinator: ToDoItemDetailsCoordinator?
    weak var delegate: (ItemDetailsDelegate & ToDoItemListViewModel)?
    
    let title = "Дело"
    
    var uploadData: ((ToDoItem) -> Void)?
    
    private let item: ToDoItem?
    
    private var id: String?
    private var text: String?
    private var priority: Priority = .basic
    private var deadline: Date? = nil
    private var hexColor: String = "#000000"
    private var isCompleted: Bool = false
    private var createdAt: Date = Date()
    
    init(fileCacheService: FileCacheService, item: ToDoItem? = nil, networkingService: NetworkingService) {
        self.fileCacheService = fileCacheService
        self.item = item
        self.networkingService = networkingService
    }
    
    func viewWillAppear(){
        guard let item = item else {
            return
        }
        uploadData?(item)
        
        id = item.id
        text = item.text
        priority = item.priority
        deadline = item.deadline
        hexColor = item.color
        isCompleted = item.isCompleted
        createdAt = item.createdAt
    }
    
    func viewWillDisappear(){
        if let coordinator = coordinator {
            coordinator.parentCoordinator?.childDidFinished(coordinator: coordinator)
        }
    }
    
    func textDidChange(text: String){
        self.text = text
    }
    
    func priorityDidChange(priority: Priority){
        self.priority = priority
    }
    
    func deadlineDidChange(deadline: Date){
        self.deadline = deadline
    }
    
    func colorDidChange(color: String){
        self.hexColor = color
    }
    
    func getColor() -> String {
        return hexColor
    }

    func deleteButtonPressed() {
        guard let item = item else {
            return
        }
        fileCacheService.delete(item: item)
        delegate?.changesAppeared()
        coordinator?.finish()
    }
    
    func cancelPressed() {
        coordinator?.finish()
    }
    
    func savePressed() {
        var newItem: ToDoItem
        if item != nil {
            guard
                let id = item?.id,
                let text = self.text
            else {
                return
            }
            newItem = ToDoItem(
                id: id,
                text: text,
                priority: priority,
                deadline: deadline,
                isCompleted: isCompleted,
                createdAt: createdAt,
                editedAt: Date(),
                color: hexColor
            )
            fileCacheService.update(item: newItem)
            self.delegate?.changesAppeared()
        } else {
            guard
                let text = self.text
            else {
                return
            }
            newItem = ToDoItem(
                text: text,
                priority: priority,
                deadline: self.deadline,
                createdAt: Date(),
                editedAt: Date(),
                color: hexColor
            )
            fileCacheService.insert(item: newItem)
            self.delegate?.changesAppeared()
        }
        coordinator?.finish()
    }
}
