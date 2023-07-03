//
//  ToDoItemListViewModel.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import Foundation

final class ToDoItemListViewModel {
    
    private let fileCache: FileCache
    private var items: [ToDoItem] = []
    private var filteredItems: [ToDoItem] = []
    private var willShowAll: Bool = true
    var isFull: Bool = true
    
    weak var coordinator: ToDoItemListCoordinator?
    
    var reloadTableView: (() -> Void)?
    
    let title = "Мои дела"
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
    }
    
    func loadView() {
        try? fileCache.load(from: "directory")
    }
    
    func viewDidLoad() {
        updateItems()
    }
    
    func viewWillDisappear() {
        try? fileCache.save(to: "directory")
    }
    
    func openDetailsView(at indexPath: IndexPath) {
        coordinator?.startToDoItemDetails(with: items[indexPath.row])
    }
    
    func deleteItem(at indexPath: IndexPath) {
        fileCache.delete(id: filteredItems[indexPath.row].id)
        filteredItems.remove(at: indexPath.row)
        updateItems()
        reloadTableView?()
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
        fileCache.add(todoItem: updatedItem)
        filteredItems[indexPath.row] = updatedItem
        filterItems()
        updateItems()
        
        reloadTableView?()
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
    
    func updateItems(){
        items = fileCache.items.map({ task in
            return task.value
        }).sorted(by: { firstItem, secondItem in
            firstItem.createdAt > secondItem.createdAt
        })
        filterItems() 
    }
    
    private func filterItems() {
        if willShowAll {
            filteredItems = items
        } else {
            filteredItems = items.filter({ $0.isCompleted == false })
        }
    }
}

extension ToDoItemListViewModel: ItemDetailsDelegate {
    func changesAppeared() {
        updateItems()
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
