//
//  ToDoItemDetailsCoordinator.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import UIKit

final class ToDoItemDetailsCoordinator: Coordinator {
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    private let fileCacheService: FileCacheService
    private let networkingService: NetworkingService
    weak var parentCoordinator: ToDoItemListCoordinator?
    private let item: ToDoItem?
    
    init(navigationController: UINavigationController, fileCacheService: FileCacheService, item: ToDoItem? = nil, networkingService: NetworkingService){
        self.navigationController = navigationController
        self.fileCacheService = fileCacheService
        self.item = item
        self.networkingService = networkingService
    }
    
    func start() {
        let toDoItemDetailsViewModel = ToDoItemDetailsViewModel(fileCacheService: fileCacheService, item: item, networkingService: networkingService)
        toDoItemDetailsViewModel.delegate = parentCoordinator?.toDoItemListViewModel
        let toDoItemDetailsViewController = ToDoItemDetailsViewController(viewModel: toDoItemDetailsViewModel)
        toDoItemDetailsViewModel.coordinator = self
        navigationController.present(toDoItemDetailsViewController, animated: true)
    }
    
    func finish(){
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinished(coordinator: self)
    }
}
