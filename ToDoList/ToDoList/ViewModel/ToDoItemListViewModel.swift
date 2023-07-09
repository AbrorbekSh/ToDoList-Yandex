//
//  ToDoItemListViewModel.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import Foundation

final class ToDoItemListViewModel {
    
    private let fileCache: FileCache
    private let networkingService: NetworkingService
    private var items: [ToDoItem] = []
    private var filteredItems: [ToDoItem] = []
    private var willShowAll: Bool = true
    var isFull: Bool = true
    
    weak var coordinator: ToDoItemListCoordinator?

    var reloadTableView: (() -> Void)?
    
    let title = "Мои дела"
    
    init(fileCache: FileCache, networkingService: NetworkingService) {
        self.fileCache = fileCache
        self.networkingService = networkingService
    }
    
    func loadView() {
//        try? fileCache.load(from: "directory")
    }
    
    func viewDidLoad() {
        Task {
            do {
                items = try await networkingService.getToDoItemList()
                updateItems()
                DispatchQueue.main.async {
                    self.reloadTableView?()
                }
            } catch {
                print("Error: getToDoItemList")
            }
        }
//        networkingService.getToDoItemList { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//            switch result {
//            case .success(let items):
//                strongSelf.items = items
//                strongSelf.updateItems()
//                strongSelf.reloadTableView?()
//            case .failure:
//                print("Something went wrong")
//            }
//        }
    }
    
    func viewWillDisappear() {
        Task {
            do {
                items = try await networkingService.updateToDoItemList(with: items)
            } catch {
                print("Error: updateToDoItemList")
            }
        }
//        try? fileCache.save(to: "directory")
    }
    
    func openDetailsView(at indexPath: IndexPath) {
        coordinator?.startToDoItemDetails(with: items[indexPath.row])
    }
    
    func deleteItem(at indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
        filteredItems.remove(at: indexPath.row)
//        reloadTableView?()
        items.removeAll { itemD in
            itemD.id == item.id
        }
        
        Task {
            do {
                let deletedItem = try await networkingService.deleteToDoItem(id: item.id)
                print(deletedItem)
                DispatchQueue.main.async {
                    self.reloadTableView?()
                }
            } catch {
                print("Error: deleteToDoItem")
            }
        }

//        fileCache.delete(id: filteredItems[indexPath.row].id)
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
//        reloadTableView?()
        
        
        
        Task {
            do {
                _ = try await networkingService.editToDoItem(item: updatedItem)
                DispatchQueue.main.async {
                    self.reloadTableView?()
                }
            } catch {
                print("Error: editToDoItem")
            }
        }
//        fileCache.add(todoItem: updatedItem)
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
//        networkingService.getToDoItemList { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//            switch result {
//            case .success(let items):
//                strongSelf.items = items
//            case .failure:
//                print("Something went wrong")
//            }
//        }
        
        
//        items = fileCache.items.map({ task in
//            return task.value
//        }).sorted(by: { firstItem, secondItem in
//            firstItem.createdAt > secondItem.createdAt
//        })
        filterItems() 
    }
    
    private func filterItems() {
        if willShowAll {
            filteredItems = items
        } else {
            filteredItems = items.filter({ $0.isCompleted == false }).sorted(by: { firstItem, secondItem in
                firstItem.createdAt > secondItem.createdAt
            })
        }
    }
}

extension ToDoItemListViewModel: ItemDetailsDelegate {
    func changesAppeared() {
//        updateItems()
        filterItems()
        Task {
            do {
                items = try await networkingService.getToDoItemList()
                updateItems()
                DispatchQueue.main.async {
                    self.reloadTableView?()
                }
            } catch {
                print("Error: getToDoItemList")
            }
        }
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
//        reloadTableView?()
    }
}
