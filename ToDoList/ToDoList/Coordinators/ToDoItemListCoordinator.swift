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
    private let networkingService: NetworkingService
    let toDoItemListViewModel: ToDoItemListViewModel
    
    init(navigationController: UINavigationController, fileCache: FileCache, networkingService: NetworkingService){
        self.navigationController = navigationController
        self.fileCache = fileCache
        self.toDoItemListViewModel = ToDoItemListViewModel(fileCache: fileCache, networkingService: networkingService)
        self.networkingService = networkingService
    }
    
    func start() {
        toDoItemListViewModel.coordinator = self
        let toDoItemListViewController = ToDoItemListViewController(viewModel: toDoItemListViewModel)
        navigationController.pushViewController(toDoItemListViewController, animated: false)
    }
    
    func startToDoItemDetails(with item: ToDoItem?){
        let toDoItemDetailsCoordinator = ToDoItemDetailsCoordinator(navigationController: navigationController, fileCashe: fileCache, item: item, networkingService: networkingService)
        toDoItemDetailsCoordinator.parentCoordinator = self
        childCoordinators.append(toDoItemDetailsCoordinator)
        toDoItemDetailsCoordinator.start()
    }
    
    func childDidFinished(coordinator: Coordinator){
        childCoordinators.removeFirst()
    }
}
