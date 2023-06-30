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
    
    weak var coordinator: ToDoItemListCoordinator?
    
    var reloadTableView: (() -> Void)?
    
    let title = "Мои дела"
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
    }
    
    func loadView() {
//        try? fileCache.loadJSON(from: "directory")
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
        fileCache.delete(id: items[indexPath.row].id)
        items.remove(at: indexPath.row)
        reloadTableView?()
    }
    
    func markAsDone(at indexPath: IndexPath) {
        let item = items[indexPath.row]
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
        items[indexPath.row] = updatedItem
        reloadTableView?()
    }
    
    func updateCell(at indexPath: IndexPath, completion:  @escaping ((ToDoItem) -> Void)) {
        let item = items[indexPath.row]
        completion(item)
    }
    
    func getNumberofItems() -> Int {
        return items.count
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
    }
}

extension ToDoItemListViewModel: ItemDetailsDelegate {
    func changesAppeared() {
        updateItems()
        reloadTableView?()
    }
}
