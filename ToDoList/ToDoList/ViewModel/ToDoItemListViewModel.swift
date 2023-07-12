//
//  ToDoItemListViewModel.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import Foundation
import CoreData

final class ToDoItemListViewModel {
    private let fileCacheService: FileCacheService
    private let networkingService: NetworkingService
    
    weak var coordinator: ToDoItemListCoordinator?
    
    let title = "Мои дела"
    
    var reloadTableView: (() -> Void)?
    
    private var items: [ToDoItem] = []
    private var filteredItems: [ToDoItem] = []
    private var willShowAll: Bool = true
    var isFull: Bool = true
    
    init(fileCacheService: FileCacheService, networkingService: NetworkingService) {
        self.fileCacheService = fileCacheService
        self.networkingService = networkingService
    }
    
    func viewDidLoad() {
        items = fileCacheService.load()
        filterItems()
        reloadTableView?()
    }
    
    func openDetailsView(at indexPath: IndexPath) {
        coordinator?.startToDoItemDetails(with: filteredItems[indexPath.row])
    }
    
    func deleteItem(at indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
        filteredItems.remove(at: indexPath.row)
        reloadTableView?()
        items.removeAll { itemD in
            itemD.id == item.id
        }
        fileCacheService.delete(item: item)
    }
    
    func markAsDone(at indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
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
        
        filteredItems[indexPath.row] = updatedItem
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = updatedItem
        }
        filterItems()
        reloadTableView?()
        fileCacheService.update(item: updatedItem)
    }
    
    func updateCell(at indexPath: IndexPath, completion:  @escaping ((ToDoItem) -> Void)) {
        let item = filteredItems[indexPath.row]
        completion(item)
    }
    
    func getNumberofItems() -> Int {
        return filteredItems.count
    }
    
    func addNewItemPressed(){
        coordinator?.startToDoItemDetails(with: nil)
    }
    
    private func filterItems() {
        if willShowAll {
            filteredItems = items.sorted(by: { firstItem, secondItem in
                firstItem.createdAt > secondItem.createdAt
            })
        } else {
            filteredItems = items.filter({ $0.isCompleted == false }).sorted(by: { firstItem, secondItem in
                firstItem.createdAt > secondItem.createdAt
            })
        }
    }
}

extension ToDoItemListViewModel: ItemDetailsDelegate {
    func changesAppeared() {
        items = fileCacheService.items
        filterItems()
        reloadTableView?()
    }
}

extension ToDoItemListViewModel: TableViewHeaderDelegate {
    func getNumberOfItmes() -> Int {
        let count = items.filter({ $0.isCompleted == true }).count
        return count
    }
    
    func showItemsByStatus() {
        willShowAll = !willShowAll
        isFull = willShowAll
        filterItems()
        reloadTableView?()
    }
}
