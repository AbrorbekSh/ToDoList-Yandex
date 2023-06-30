//
//  ToDoItemListCoordinator.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import UIKit

final class ToDoItemListCoordinator: Coordinator {
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    private let fileCache: FileCache
    let toDoItemListViewModel: ToDoItemListViewModel
    
    init(navigationController: UINavigationController, fileCache: FileCache){
        self.navigationController = navigationController
        self.fileCache = fileCache
        self.toDoItemListViewModel = ToDoItemListViewModel(fileCache: fileCache)
    }
    
    func start() {
        toDoItemListViewModel.coordinator = self
        let toDoItemListViewController = ToDoItemListViewController(viewModel: toDoItemListViewModel)
        navigationController.pushViewController(toDoItemListViewController, animated: false)
    }
    
    func startToDoItemDetails(with item: ToDoItem?){
        let toDoItemDetailsCoordinator = ToDoItemDetailsCoordinator(navigationController: navigationController, fileCashe: fileCache, item: item)
        toDoItemDetailsCoordinator.parentCoordinator = self
        childCoordinators.append(toDoItemDetailsCoordinator)
        toDoItemDetailsCoordinator.start()
    }
    
    func childDidFinished(coordinator: Coordinator){
        childCoordinators.removeFirst()
    }
}
