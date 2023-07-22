//
//  ToDoItemListViewModel.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import Foundation
import CoreData

final class ToDoItemListViewModel: ObservableObject {
    
    weak var coordinator: ToDoItemListCoordinator?
    
    private let fileCacheService: FileCacheService
    
    private var items: [ToDoItem] = []
    var isFull: Bool = true
    let title = "Мои дела"
    
    @Published var filteredItems: [ToDoItem] = []
    
    init(fileCacheService: FileCacheService) {
        self.fileCacheService = fileCacheService
    }
    
    func viewDidLoad() {
        items = fileCacheService.load()
        filteredItems = items
    }
    
    func openDetailsView(with item: ToDoItem) {
        coordinator?.startToDoItemDetails(with: item)
    }
    
    func deleteItem(item: ToDoItem) {
        if let index = filteredItems.firstIndex(where: { $0.id == item.id }) {
            filteredItems.remove(at: index)
        }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            fileCacheService.delete(item: items[index])
            items.remove(at: index)
        }
    }
    
    func markAsDone(item: ToDoItem) {
        guard !item.isCompleted else {
            return
        }
        
        let updatedItem = ToDoItem( id: item.id,
                                    text: item.text,
                                    priority: item.priority,
                                    deadline: item.deadline,
                                    isCompleted: true,
                                    createdAt: item.createdAt,
                                    editedAt: item.editedAt,
                                    color: item.color)
        
        if let index = filteredItems.firstIndex(where: { $0.id == item.id }) {
            filteredItems[index] = updatedItem
        }
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = updatedItem
        }
        filterItems()
        fileCacheService.update(item: updatedItem)
    }
    
    func addNewItemPressed(){
        coordinator?.startToDoItemDetails(with: nil)
    }
    
    private func filterItems() {
        if isFull {
            filteredItems = items
        } else {
            filteredItems = items.filter({ $0.isCompleted == true }).sorted(by: { firstItem, secondItem in
                firstItem.createdAt > secondItem.createdAt
            })
        }
    }
}

extension ToDoItemListViewModel: ItemDetailsDelegate {
    func changesAppeared() {
        items = fileCacheService.items
        filterItems()
    }
}

extension ToDoItemListViewModel: TableViewHeaderDelegate {
    func getNumberOfItems() -> Int {
        let count = items.filter({ $0.isCompleted == true }).count
        return count
    }
    
    func showItemsByStatus() {
        isFull = !isFull
        filterItems()
    }
}
